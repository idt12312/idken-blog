---
layout: post
title: STM32のFlashにデータを保存する (CubeMX+HAL編)
category: マイコン
tag:
    - マイコン
    - STM32
comments: true
thumb: /images/thumb_stm32.jpg
---
以前書いたSTM32のFlashにデータを保存する話のCubeMX+HALバージョンの話です。

# はじめに
以前STM32のFlashにデータを保存する話を書きました。

[**STM32のFlashにデータを保存する**](/posts/2017-09-30-stm32_flash)

この記事ではStandard Peripheral Libraryの例を載せていました。
STM32は今やCubeMX+HALでの開発が主流になっているので、
CubeMX+HALでの実装例を追加情報としてこの記事に書いておきます。

STM32のFlashの動作やリンカスクリプトのいじり方は[以前の記事](/posts/2017-09-30-stm32_flash)と同じなので、
そちらを見てください。


# CubeMX + HALでの実装
F4Discoveryで動作を確認しています。
どのSTM32マイコンでも以降の説明は成り立つはずですが、
Flashのセクターの区切り方や番地はチップによって異なるのでよく確認してください。

## CubeMXでの作業
**ありません。**
何も設定しなくてもFLashは使えるようになっています。

Flashの削除や書き込み作業の完了割り込みを使いたい場合には、
CubeMXのNVICの設定で以下のような項目をいじると割り込みが使えるようになります。

![](/images/stm32_flash_cubemx.png)


## FlashをいじるコードのHALでの実装
[以前の記事](/posts/2017-09-30-stm32_flash)に書いたものと同じ機能をHALで実装しました。


```c
#define BACKUP_FLASH_SECTOR_NUM     FLASH_SECTOR_1
#define BACKUP_FLASH_SECTOR_SIZE    1024*16

// Flashから読みだしたデータを退避するRAM上の領域
// 4byteごとにアクセスをするので、アドレスが4の倍数になるように配置する
static uint8_t work_ram[BACKUP_FLASH_SECTOR_SIZE] __attribute__ ((aligned(4)));

// Flashのsector1の先頭に配置される変数(ラベル)
// 配置と定義はリンカスクリプトで行う
extern char _backup_flash_start;


// Flashのsectoe1を消去
bool Flash_clear()
{
    HAL_FLASH_Unlock();

    FLASH_EraseInitTypeDef EraseInitStruct;
    EraseInitStruct.TypeErase = FLASH_TYPEERASE_SECTORS;
    EraseInitStruct.Sector = BACKUP_FLASH_SECTOR_NUM;
    EraseInitStruct.VoltageRange = FLASH_VOLTAGE_RANGE_3;
    EraseInitStruct.NbSectors = 1;

    // Eraseに失敗したsector番号がerror_sectorに入る
    // 正常にEraseができたときは0xFFFFFFFFが入る
    uint32_t error_sector;
    HAL_StatusTypeDef result = HAL_FLASHEx_Erase(&EraseInitStruct, &error_sector);

    HAL_FLASH_Lock();

    return result == HAL_OK && error_sector == 0xFFFFFFFF;
}

// Flashのsector1の内容を全てwork_ramに読み出す
// work_ramの先頭アドレスを返す
uint8_t* Flash_load()
{
    memcpy(work_ram, &_backup_flash_start, BACKUP_FLASH_SECTOR_SIZE);
    return work_ram;
}

// Flashのsector1を消去後、work_ramにあるデータを書き込む
bool Flash_store()
{
    // Flashをclear
    if (!Flash_clear()) return false;

    uint32_t *p_work_ram = (uint32_t*)work_ram;

    HAL_FLASH_Unlock();

    // work_ramにあるデータを4バイトごとまとめて書き込む
    HAL_StatusTypeDef result;
    const size_t write_cnt = BACKUP_FLASH_SECTOR_SIZE / sizeof(uint32_t);

    for (size_t i=0; i<write_cnt; i++)
    {
        result = HAL_FLASH_Program(
                    FLASH_TYPEPROGRAM_WORD,
                    (uint32_t)(&_backup_flash_start) + sizeof(uint32_t) * i,
                    p_work_ram[i]
                );
        if (result != HAL_OK) break;
    }

    HAL_FLASH_Lock();

    return result == HAL_OK;
}
```

HALのライブラリ関数のパラメータについてはHALのヘッダファイルやソースファイルに書いてあるので、
そちらを見てください。

※Flashの削除は```HAL_FLASH_Erase```ではなく```HAL_FLASHEx_Erase```であることに注意してください。


## リンカスクリプトの編集
[以前の記事](/posts/2017-09-30-stm32_flash)の通りにリンカスクリプトの編集が必要になります。
