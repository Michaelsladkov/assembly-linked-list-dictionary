# Assignment №2:  Dictionary in assembly
---
Second assignment on ITMO CSE Low Level Programming course


### [Task](https://gitlab.se.ifmo.ru/programming-languages/cse-programming-languages-fall-2021/assignment-dictionary)

## Comment

Реализация статически задаваемой коллекции с парами ключ - значение. Выполнено на ассемблере для x64 с использованием системных вызовов Linux.

### Назначение файлов:

Пары записываются с помощью в память colon.inc. Список записываемых в память блоков указывается в words.inc. 

lib.asm - библиотека ввода/вывода, напсианная в первой лабораторной работе

lib.inc - заголовочный файл библиотеки

dict.asm - библиотека списка, реализация обхода связного списка с поиском по ключу

dict.asm - заголовочный файл библиотеки списка