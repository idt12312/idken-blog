---
layout: post
title: FreeRTOSのタスクの動作状況を調べる
category: FreeRTOS
tag:
    - FreeRTOS
    - マイコン
comments: true
thumb: http://www.freertos.org/logo.jpg
---
FreeRTOS上で動作しているタスクのスタックサイズ、実行されていた時間を調べてみました。


# FreeRTOSのタスクの稼働状況を調べたい
現在、マイクロマウスのファームウェアの開発にFreeRTOSを使っています。

![MIZUHOv2](/images/mizuhov2_front.jpg){:data-action="zoom"}

FreeRTOS上の各タスクがどのくらいのスタックを使っているのか、
どのくらいCPUの時間的リソースを使っているのかを知りたくなったので、
それらを知る方法を調べてみました。

するとどうやらFreeRTOSには標準でプロファイリング機能が用意されていたことが分かりました。

[**FreeRTOS:Task Utilities**](http://www.freertos.org/a00021.html)


これらの機能のうち、次の2つのことを実現する方法を紹介したいと思います。

* タスクの使用しているスタックサイズを調べる
* タスクの実行時間を調べる


# スタックサイズを調べる

この関数を使います。

```c
void vTaskList( char *pcWriteBuffer );
```

十分なサイズのバッファを確保してこの関数に渡すと、タスクの情報がいい感じに整形されて文字列としてバッファに書き込まれます。


vTaskListを使うには、FreeRTOSConfig.hに次の設定を追加します。
この設定によってvTaskList()が使用可能になります。

```c
#define configUSE_TRACE_FACILITY		1
#define configUSE_STATS_FORMATTING_FUNCTIONS 1
```

タスクの情報を取得して表示するときはこんな感じにします。

```c
char msg_buffer[512];
vTaskList(msg_buffer);

printf("%s", msg_buffer);
```

どれだけのメモリが必要か事前に分からず、バッファオーバーランの可能性があるので注意してください。
FreeRTOSのドキュメントによるとタスク1つにつき40byteのメモリが確保してあれば十分みたいです。

これらの処理を実際に開発中のマイクロマウスのファームウェアに埋め込んで実行してみると、
次のような結果が表示されました。

```
main               R    1    183    1
IDLE               R    0    110    2
control            B    3    355    6
battery monitor    B    1    435    4
wall detect        B    2    357    5
Tmr Svc            S    2    218    3
```

これらの値は左から順に次のような意味を持っています。

* タスク名:xTaskCreateで設定した文字列
* タスクの実行状態:'B'(Block), 'R'(Ready), 'D'(Deleted), 'S'(Suspended)
* 優先度
* 現在のスタックサイズ
* タスク番号

スタックサイズに限らず、実行状態も取得することができます。

この関数で得られるスタックサイズというのはその瞬間の値です。
起動してからのスタックサイズの最大値を取得する方法もあります。

そのためには次の関数を使います。

```c
UBaseType_t uxTaskGetStackHighWaterMark ( TaskHandle_t xTask );
```

タスクハンドル(xTaskCreateしたときに割り当てられる)を渡すと、
該当タスクのスタックサイズの最大値を取得することができます。

詳細はFreeRTOSのドキュメントを参照してください。

[**FreeRTOS:uxTaskGetStackHighWaterMark()**](http://www.freertos.org/uxTaskGetStackHighWaterMark.html)


# 実行時間を調べる

タスクが実行されていた時間を調べる方法は、
FreeRTOSのサイトに解説ページがありました。

[**FreeRTOS:Run Time Statistics**](http://www.freertos.org/rtos-run-time-stats.html)

微妙に使いにくいというかクセがあるので、公式のサンプルとは違うものを使って紹介します。
(もしかしたら正しくない方法かもしれない)


タスクの実行時間を調べるには、次の関数を使います。

```c
void vTaskGetRunTimeStats( char *pcWriteBuffer );
```

先程のvTaskListと同様に、整形された文字列として時間に関する情報を得ることができます。


vTaskGetRunTimeStatsを使うには、
portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()と
portGET_RUN_TIME_COUNTER_VALUE()というマクロをユーザー側で定義する必要があります。

FreeRTOSはRTOSのTick以下の時間はカウントしていません。
しかしタスクはTick以下の時間でガンガン切り替わっていくので、
タスクが実行されていた時間を正確に知るにはTick以下の時間分解能を持つカウンタが必要になります。
FreeRTOS内部にこのようなカウンタは持っていないので、ユーザーが提供しなければいけません。
FreeRTOSのドキュメントによると、このカウンタはTickの10~100倍の速度で動いているのが好ましいみたいです(長さの調整方法は後述)。
このカウンタというのは大抵の場合マイコンのタイマーを使うのが簡単です。

portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()にはカウンタを初期化する処理を、
portGET_RUN_TIME_COUNTER_VALUE()にはカウンタの値を取得する処理を定義してやります。

今回は開発中のマイクロマウスの環境(STM32)に合わせて設定例を紹介します。
FreeRTOSはTick=1msで動作させているので、
10倍の速度である100usでカウントアップするタイマーをFreeRTOSから使えるように設定していきます。

まずはタイマーを操作するために次の関数を用意します。
STM32以外のマイコンにおいても同様の関数を作れば利用可能です。
100usもだいたいでOKです。

```c
#include "stm32f4xx.h"

void ProfilerTimer_init()
{
	// APB1 = 84MHz
    // TIM6のPrescalerを8400-1に設定することで1cout=100usになる
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM6 , ENABLE);

	TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
	TIM_TimeBaseStructInit(&TIM_TimeBaseStructure);
	TIM_TimeBaseStructure.TIM_Period = 0xffff;
	TIM_TimeBaseStructure.TIM_Prescaler = 8400 - 1;
	TIM_TimeBaseStructure.TIM_ClockDivision = 0;
	TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
	TIM_TimeBaseStructure.TIM_RepetitionCounter = 0;
	TIM_TimeBaseInit(TIM6, &TIM_TimeBaseStructure);
}

uint32_t ProfilerTimer_start()
{
	TIM6->CNT = 0;
	TIM_Cmd(TIM6, ENABLE);
}

uint32_t ProfilerTimer_get()
{
	return TIM6->CNT;
}
```

ここではSTM32の16bitタイマー(TIM6)を使っていますが、
カウント値は32bit値で返すことになっているので、32bitカウントできるものの方が好ましいです。


FreeRTOSConfig.hには次の設定を追加します。
先程のタイマーを操作する関数をマクロに設定しています。

```c
#define configGENERATE_RUN_TIME_STATS           1
#define configUSE_STATS_FORMATTING_FUNCTIONS    1

#define portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()    ProfilerTimer_init()
#define portGET_RUN_TIME_COUNTER_VALUE()            ProfilerTimer_get()
```

実際にタスクの実行時間を調べるには次のようにします。

```c
ProfilerTimer_start();

/*
    色々な処理
*/

char msg_buffer[512];
vTaskGetRunTimeStats(msg_buffer);

printf("%s", msg_buffer);
```

ProfilerTimer_start()を呼んでからvTaskGetRunTimeStats()を呼ぶまでの間に実行されたタスクの実行状況を知ることができます。

実際にこれらコードを実行してみると次のような出力が得られました。

```
main               864        7%
IDLE               8736        78%
battery monitor    1        <1%
wall detect        505        4%
control            997        8%
Tmr Svc            0        <1%
```

これらの値は左から順に次のような意味を持っています。

* タスク名:xTaskCreateで設定した文字列
* タスクが実行されていた時間:カウンタの値
* タスクが占有していた時間の割合[%]

今回は100usでタイマーをカウントしているので、mainの864というのは8640[us]に相当します。
ProfilerTimer_start()を呼んでからvTaskGetRunTimeStats()が呼ばれるまでに、
"main"という名前のタスクは8640[us]の時間だけ実行されていたということになります。

## ポイント1:タイマーのカウント周期
タイマーのカウントアップをもっと早くしていくと計測時間の分解能は上がっていきますが、
タイマーがオーバーフローする可能性が出てきます。
FreeRTOS内ではタイマーのオーバーフローが考慮されていないので、
タイマーがオーバーフローすると表示される値がおかしくなってしまいます。

## ポイント2:計測する区間
vTaskGetRunTimeStats()で得られる情報は、
ProfilerTimer_start()を呼んでからvTaskGetRunTimeStats()が呼ばれるまでの
タスクの実行時間の積算値です。
計測していた区間における積算値しか得られないので、
ある瞬間の状態を知りたいのであれば計測区間を限定すべきです。

また、計測している時間が長ければ長いほどタイマーのオーバーフローの可能性は高まるので、
計測したい最小の区間で計測を行うべきです。

FreeRTOSの解説にあるコードではportCONFIGURE_TIMER_FOR_RUN_TIME_STATS()でタイマーを初期化&動作開始しているので、
FreeRTOSが起動してからの情報となっています。
これだとすぐにタイマーがオーバーフローしたり、
初期化処理などの特に知りたくない情報も積算されてしまいます。
なのでFreeRTOSのサンプルから少し変えて、タイマーのスタートは
portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()で行わず、
自分でタイマーをスタートさせる実装にしてみました。


## ポイント3:計測は一度しかできない
FreeRTOSは内部で各タスクが実行されていた**累計時間**を保持しているため、
vTaskGetRunTimeStats()によってタスクが実行されていた時間を知ることができます。

しかしこの内部の累計時間はリセットすることができません。
タイマーをリセットしても累計時間の更新が止まるだけで、リセットされません。
なのでFreeRTOSを一度起動したらある区間で一度だけしか計測をすることができず、
2回目の計測を行ったとしても、その結果は1回目の計測値との積算値になってしまいます。

もし解決方法をご存知の方がいましたら是非教えてください。


# タスクの情報の生データを取得する
ここまでで、全てのタスクの情報を整形された文字列として取得する方法を紹介しました。
実はuxTaskGetSystemState()という関数を使うことでこれらの情報を文字列ではなく、
生データ(Cの構造体)として取得することもできます。

使い方はFreeRTOSの公式サイトに詳しく書かれているので、そちらを参考にしてください。

[**FreeRTOS:uxTaskGetSystemState()**](http://www.freertos.org/uxTaskGetSystemState.html)

vTaskList()やvTaskGetRunTimeStats()も内部でこの関数を使っているみたいです。


# おわりに
FreeRTOSで動くタスクのスタックサイズ、実行時間を知る方法を紹介しました。
vTaskListはいい感じに使えますが、vTaskGetRunTimeStatsの方は微妙ですね。

