---
layout: post
title: Eclipse+GDB+openocdでFreeRTOSの複数のタスクを追う
category: FreeRTOS
tag:
    - FreeRTOS
    - Eclipse
    - マイコン
comments: true
thumb: /images/thumb_freertos.jpg
---
OpenOCDやJ-Link GDB Serverを使って、FreeRTOS上で動くすべてのタスクをデバッガから同時に追う


# はじめに
FreeRTOSで動く複数のタスクをデバッグをするとき、
下の画像のように全てのタスク(現在実行はされていないも含む)を同時に見たいですよね？

![](/images/freertos_debug_0.png){:data-action="zoom"}

ただ、それ用にOpenOCDやJ-Link GDB Serverを設定しないとこういうことはできないので、
今回はその設定方法を紹介したいと思います。

# 実行環境
以下の環境を想定して説明をしていきます。

## 開発環境(PC側)

* Eclipse NEON.2 v4.6.2 + CDT
* GNU ARM Eclipse Plug-ins v3.2.1
* [arm-none-eabi 4.9.3 2015q3](https://launchpad.net/gcc-arm-embedded/+download)
* [OpenOCD v0.10.0-201701241841](https://github.com/gnu-mcu-eclipse/openocd/releases)
* (J-Link GDB Server V6.12e)

OpenOCDはGNU ARM Eclipse Plug-insと同じところがリリースしているものを使用しています。


## 実行環境(ハード・ファーム)

* STM32F4Discovery (STM32F407VG)
* FreeRTOS v9.0.0
* Standard Periperal Library V1.8.0

参考のため、今回使用したeclipseのプロジェクトはzip化してここに置いておきます。(すんなりEclipseにimportできるはず)

[**freertos_test.zip**](https://1drv.ms/u/s!Ao1lcte3fsQvuzvooYciLbyGW33B)

余談ですが、GNU ARM Eclipse Plug-insを使って、
STM32F4 + StandardPeripheralLibrary + FreeRTOSのプロジェクトを作るときはいつもこれをもとにしています。
よかったら使って下さい。


# 今回使うプログラム
動作に関係する本質的な部分だけを抜粋しています。

GREENのLEDを500*2ms周期で点滅させるTaskAと
タスクの引数に応じて点滅させるLED、周期を設定できるTaskBを関数として定義しています。
そしてTaskAから"TaskA"というタスク、TaskBから"TaskB1","TaskB2"という合計3つのタスクを生成しています。

```c
// LEDとpinの対応
#define LED_GREEN   GPIO_Pin_12
#define LED_ORANGE  GPIO_Pin_13
#define LED_RED     GPIO_Pin_14
#define LED_BLUE    GPIO_Pin_15

// TaskBに渡す引数の型
typedef struct {
	uint16_t	pin;
	TickType_t	period;
} TaskB_arg_t;

// TaskBに渡す引数
static const TaskB_arg_t taskB1_arg = {.pin = LED_ORANGE, .period = 1000};
static const TaskB_arg_t taskB2_arg = {.pin = LED_RED, .period = 2000};

void TaskA(void *args)
{
	(void *)args;

	TickType_t last_wake_tick = xTaskGetTickCount();
	while (1) {
		vTaskDelayUntil(&last_wake_tick, 500);
		last_wake_tick = xTaskGetTickCount();
		GPIO_ToggleBits(GPIOD, LED_GREEN);
	}
}

void TaskB(void *args)
{
	const TaskB_arg_t *task_arg = (const TaskB_arg_t*)args;

	TickType_t last_wake_tick = xTaskGetTickCount();
	while (1) {
		vTaskDelayUntil(&last_wake_tick, task_arg->period);
		last_wake_tick = xTaskGetTickCount();
		GPIO_ToggleBits(GPIOD, task_arg->pin);
	}
}

void hardware_init()
{
	// GPIOの設定
	// PD12:Green PD13:Orage PD14:Red PD15:Blue
	// LEDは1出力で光る
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	GPIO_InitTypeDef gpio_init;
	GPIO_StructInit(&gpio_init);
	gpio_init.GPIO_Mode = GPIO_Mode_OUT;
	gpio_init.GPIO_Pin = LED_GREEN | LED_ORANGE | LED_RED | LED_BLUE;
	gpio_init.GPIO_Speed = GPIO_Speed_2MHz;
	gpio_init.GPIO_OType = GPIO_OType_PP;
	GPIO_Init(GPIOD, &gpio_init);

	// LEDｌを消灯
	GPIO_Write(GPIOD, 0);
}

int main()
{
	// 割り込み優先度をpre-emption priorityに4bit割り当てる
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);

	// GPIOの設定
	hardware_init();

	// タスクを三つ作成
	xTaskCreate(TaskA, "TaskA", 256, NULL, 0, NULL);
	xTaskCreate(TaskB, "TaskB1", 256, &taskB1_arg, 0, NULL);
	xTaskCreate(TaskB, "TaskB2", 256, &taskB2_arg, 0, NULL);

	// FreeRTOS動作開始
	vTaskStartScheduler();

	while(1);

	return 0;
}

```

ちなみに動作させるとこんな感じでLEDが光ります。

![](/images/freertos_led.gif)


# 全てのタスクをデバッガで追う

特に設定をせず、普通にOpenOCD+GDBでデバッグをしてみます。
試しにTaskAにbreak pointを張ってTaskAを実行中に動作を一時停止すると、デバッガからはこんな感じで見えます。

![](/images/freertos_debug_non.png){:data-action="zoom"}

TaskAの内容は表示されるのですが、同時に実行中の他のタスクTaskB1,TaskB2(正確にはsuspend中)の情報は何も見えません。

ところが後述する設定をするとこんな感じで、TaskAの実行中に動作を止めたのに他の起動中のタスクの状態(スタック内容など)も見ることができるようになります。

![](/images/freertos_debug_1.png){:data-action="zoom"}

画像中で表示されているタスク名は、xTaskCreateでタスクを生成した際に設定した文字列になっています。

あるタスクで条件を満たしたときにbreakし、その時の他のタスクの状況を見たいときにはとても便利です。

さらにもう一つ、OSを使っているからこそのおもしろい現象も観察できます。
今回はTAskB1,TaskB2の処理内容は同じTaskBという関数ですが、タスクへの引数の変えることで実際の動作内容を変えています。
Eclipseのデバッグ画面からTaskB1を選択した場合とTaskB2を選択した場合で変数の内容が変わっています。
画像中の下方のソースの表示はどちらも一緒なのに、右側のスタック変数の値が変わっています。

![](/images/freertos_debug_21.png){:data-action="zoom"}

![](/images/freertos_debug_22.png){:data-action="zoom"}

このように引数を変えただけのタスクもきちんと区別をして、タスクのスタックを追ってくれるようになります。

それではこのようなことをするための設定について説明をしていきます。
OpenOCDとJ-Linkで設定すべきものが違うので、該当する方だけを気にして下さい。

# OpenOCDでの設定
OpenOCDではOpenOCD自体の設定に加え、ソースやリンカの設定も必要となります。

## 1. OpenOCD自体の設定
OpenOCD自体にFreeRTOSをはじめとする様々なRTOSに対してマルチスレッド(タスク)のデバッグをサポートしています。

[OpenOCD User's Guide (21.6 RTOS Support)](http://openocd.org/doc/html/GDB-and-OpenOCD.html)

ここに書いてある通り、OpenOCDの設定スクリプト(-s xxx.cfgで指定するやつ)の中に

```
$_TARGETNAME configure -rtos FreeRTOS
```

のように書いてやればOKです。
ただ、既存のスクリプトファイルを編集するのは面倒なので、OpenOCDの起動コマンドを

```
openocd -s "xxx.cfg" -c "$_TARGETNAME configure -rtos FreeRTOS"
```

のようにしてやることでも同じことができます。
GNU ARM Eclipse Plug-insの"GDB OpenOCD Debugging"の設定は次のようにします。

![](/images/freertos_openocd_config.png){:data-action="zoom"}

## 2. ソース、リンカの設定
もし古いバージョンのFreeRTOSを使っている場合はここまでの設定だけでOKなのですが、
最近のバージョンのFreeRTOS(v7.5.3以降)を使っている場合はもうひと手間必要となります。

OpenOCDがFreeRTOSの状態を追うために、実行バイナリ中の"uxTopUsedPriority"という変数を参照するのですが、
FreeRTOSのv7.5.3以降はこの変数がなくなってしまいました。

なのでOpenOCDの開発側は自分で"uxTopUsedPriority"を適切に定義してくれと言っています。
uxTopUsedPriorityはここみたいに定義しておけばOKです。

[OpenOCD FreeRTOS-openocd.c](https://github.com/gnu-mcu-eclipse/openocd/blob/gnu-mcu-eclipse-dev/contrib/rtos-helpers/FreeRTOS-openocd.c)

この内容をコピーしてmain.cなどに追加してもいいですし、プロジェクトに上記リンク先にある"FreeRTOS-openocd.c"を追加するのでもOKです。

変数をソース中で定義をしたら、リンカの設定も確認する必要があります。
今、プロジェクト内でuxTopUsedPriorityという変数はどこからも参照されていないので、
リンカオプションで--gc-sectionsフラグが有効になっているとリンク時にこの変数は消されてしまいます。
(GNU ARM Eclipse Plug-insでプロジェクトを作った場合はデフォルトでこの設定が有効になります。)

リンカの設定で--gc-sectionsフラグが有効な場合は、さらに"-Wl,--undefined=uxTopUsedPriority"を加えてやることで
uxTopUsedPriorityという変数は参照されてなくてもリンク時に削除されなくなります。

Eclipseではプロジェクトのプロパティから次のように設定することになります。

![](/images/freertos_linker.png){:data-action="zoom"}


ここまでの設定をすることでようやくOpenOCDでFreeRTOSの全てのタスクを同時に追えるようになります。


# JlinkGDBServerでの設定
J-Link GDB Serverを使う場合もJ-Link GDB Serverの追加の設定が必要となります。
ただしJLinkの場合は非常にシンプルで、J-Link GDB Serverの起動オプションに

```
-rtos GDBServer/RTOSPlugin_FreeRTOS
```

を追加するだけです。
EclipseのGNU ARM Eclipse Plug-insの"GDB SEGGER J-Link Debugging"の設定は次のようにします。

![](/images/freertos_jlink_config.png){:data-action="zoom"}


# おわりに
今回はEclipse + GNU ARM Eclipse Plug-ins前提で説明をしましたが、本質的にはGDB + OpenOCD(JLinkGDBServer)なので、
Eclipseを使っていない場合も同様の設定をすることで同じことができるようになると思います。

