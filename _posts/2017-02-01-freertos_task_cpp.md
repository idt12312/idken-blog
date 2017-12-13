---
layout: post
title: C++でFreeRTOSのタスクをいい感じにつくる
category: FreeRTOS
tag:
    - FreeRTOS
    - C++
comments: true
thumb: http://www.freertos.org/logo.jpg
---
FreeRTOSのタスクをC++のクラスの機能を使っていい感じにつくる話


# C++からもFreeRTOSを使いたい
FreeRTOSはC言語のみでできていて、インターフェースはもちろんC的なインターフェースです。
例えばタスクtask_funcを追加するときには

```c
xTaskCreate(task_func, /*...スタックの設定とか...*/);
```  

とし、FreeRTOSで定められた形

```c  
void task_func(void *)
```

をした関数への関数ポインタを渡してやります。


C言語のみで開発をしているときはこれでいいのですが、C++も使って開発をする際に少し困ったことが起こります。
xTaskCreateにはC言語のような普通の関数か、statisメンバ関数しか登録することができません。
理由はC++の普通の(staticでない)メンバ関数は  

```c
void (*fp_func)() = obj.member_func;
```  

のようにして関数ポインタを扱うことができないからです。
普通のメンバ関数はクラスではなくインスタンス(実体)に結びついているものなので、メンバ関数を呼ぶ際にインスタンスも指定する必要があります。
なのでC++ではメンバ関数ポインタはC言語の関数ポインタとは違う扱いになります。
([C++におけるメンバ関数のポインタについての解説](http://www7b.biglobe.ne.jp/~robe/cpphtml/html03/cpp03057.html))

C++を使うからにはクラスを作って色々構成したいのですが、staticメンバ関数しかタスクとして登録できないとなると不便と感じることがあります。
なのでC++のクラスの機能をうまく使いつつタスクを表現するクラスを作って、便利にタスクがつくれないかと考えました。


# Solution
こんな感じのクラスを作ってみました。

<script src="https://gist.github.com/idt12312/b7f8379ad2b0b7c72079e3bb6723df12.js"></script>

実際にタスクを作りたいときはこのTaskBaseクラスを継承して、task()というメンバ関数をoverrideしてやります。
こんな感じです。

```cpp
class TestTask : public TaskBase {
public:
	TestTask() : TaskBase("test task", 1, 256) 
    {
    }

	virtual ~TestTask()
    {
    }

private:
	virtual void task()
    {
        while (1) {
            // タスクの動作
        }
    }
};
```

実際にタスクを作成し、動作させるときはこんな感じです。

```c
int main()
{
    TestTask test_task();

    test_task.create_task();
    //
    // ほかにもタスクを作成する
    //

    vTaskStartScheduler();
}
```

## 解説
FreeRTOSのtaskcreateには普通の関数かstaticなメンバ関数しか渡せません。
なのでtask_entry_pointというstaticメンバ関数を定義しておいて、それをxTaskCreateに渡してやります。

create_task()呼んだときにxTaskCreateを呼び出していて、この時にタスクへの引数(void *)としてthisを渡しています。
複数のタスクを作った場合、すべて共通のtask_entry_point関数が呼ばれますが、
task_entry_point関数の引数がオブジェクトごとに違うので、思い通りのインスタンスのメンバ関数を呼ぶことができます。

## ちなみに
余計かもしれませんが、継承先のクラスでちゃんと基底クラスであるTaskBaseを初期化してほしいので
デフォルトコンストラクタを禁止しています。(スタックとかの設定を把握せずに設定されると困るのでデフォルト値を設けていません)

