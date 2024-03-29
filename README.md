# AuServiceTasks
Задания по курсу Газпромнефть Автоматики-Сервис. Решения задач на языке Python. Для курса по БД задания на языке PLpgSQL/SQL.

---
## Спринт 1
---

<details>
<summary>
<b>Ближайший ноль (<a href="NearestZero.py">NearestZero.py</a>)</b>
</summary>

#### Условие
Улица, на которой хочет жить Тимофей, имеет длину n, то есть состоит из n одинаковых идущих подряд участков. 
На каждом участке либо уже построен дом, либо участок пустой. 
Тимофей ищет место для строительства своего дома. 
Он очень общителен и не хочет жить далеко от других людей, живущих на этой улице.

Чтобы оптимально выбрать место для строительства, 
Тимофей хочет для каждого участка знать расстояние до ближайшего пустого участка. 
(Для пустого участка эта величина будет равна нулю –— расстояние до самого себя).

Ваша задача –— помочь Тимофею посчитать искомые расстояния. 
Для этого у вас есть карта улицы. 
Дома в городе Тимофея нумеровались в том порядке, в котором строились, 
поэтому их номера на карте никак не упорядочены. Пустые участки обозначены нулями.

#### Формат ввода
В первой строке дана длина улицы —– n (1 ≤ n ≤ 106). 
В следующей строке записаны n целых неотрицательных чисел — номера домов и обозначения пустых участков на карте (нули). 
Гарантируется, что в последовательности есть хотя бы один нуль. 
Номера домов (положительные числа) уникальны и не превосходят 10^9.

#### Формат вывода
Для каждого из участков выведите расстояние до ближайшего нуля. 
Числа выводите в одну строку, разделяя их пробелами.

#### Пример
<table><tbody>
  <tr>
    <td><b>Ввод</b></td>
    <td><b>Вывод</b></td>
  </tr>
  <tr>
    <td valign='top'>
5<br>
0 1 4 9 0<br>

</td>
  <td valign='top'>
0 1 2 1 0<br>
</td>
  </tr>
</tbody></table>

</details>

------

<details>
<summary>
<b>Ловкость рук (<a href="sleight_of_hand.py">sleight_of_hand.py</a>)</b>
</summary>

#### Условие
Гоша и Тимофей нашли необычный тренажёр для скоростной печати и хотят освоить его.
Тренажёр представляет собой поле из клавиш 4× 4, в котором на каждом раунде появляется конфигурация цифр и точек.
На клавише написана либо точка, либо цифра от 1 до 9.
В момент времени t игрок должен одновременно нажать на все клавиши, на которых написана цифра t.
Гоша и Тимофей могут нажать в один момент времени на k клавиш каждый.
Если в момент времени t были нажаты все нужные клавиши, то игроки получают 1 балл.

Найдите число баллов, которое смогут заработать Гоша и Тимофей, если будут нажимать на клавиши вдвоём.

#### Формат ввода
В первой строке дано целое число k (1 ≤ k ≤ 5).

В четырёх следующих строках задан вид тренажёра –— по 4 символа в каждой строке.
Каждый символ —– либо точка, либо цифра от 1 до 9.
Символы одной строки идут подряд и не разделены пробелами.

#### Формат вывода
Выведите единственное число –— максимальное количество баллов, которое смогут набрать Гоша и Тимофей.

#### Пример
<table><tbody>
  <tr>
    <td><b>Ввод</b></td>
    <td><b>Вывод</b></td>
  </tr>
  <tr>
    <td valign='top'>
3<br>
1231<br>
2..2<br>
2..2<br>
2..2<br>

</td>
  <td valign='top'>
2<br>
</td>
  </tr>
</tbody></table>

</details>

---
## Спринт 2
---

<details>
<summary>
<b>Генератор скобок (<a href="brackets_generator.py">brackets_generator.py</a>)</b>
</summary>

#### Условие
Необходимо реализовать функцию, генерирующую скобочную последовательность, в зависимости от входного параметра.
Сгенерировать последовательности длины 2n в лексикографическом порядке —– 
последовательности состоят из ( и ) и открывающая скобка идёт раньше закрывающей.

#### Формат ввода
На вход функция принимает n — целое число от 0 до 10.

#### Формат вывода
Функция должна напечатать все возможные скобочные последовательности заданной длины в алфавитном (лексикографическом) порядке.

#### Пример
<table><tbody>
  <tr>
    <td><b>Ввод</b></td>
    <td><b>Вывод</b></td>
  </tr>
  <tr>
    <td valign="top">
3<br>

</td>
    <td valign="top">
((()))<br>
(()())<br>
(())()<br>
()(())<br>
()()()<br>

</td>
  </tr>
</tbody></table>

</details>

---
<details>
<summary>
<b>Большое число (<a href="largest_number.py">largest_number.py</a>)</b>
</summary>

#### Условие
Даны числа. Нужно определить, какое самое большое число можно из них составить.

#### Формат ввода
В первой строке записано n — количество чисел. n <= 100.
Во второй строке через пробел записаны n чисел, каждое из которых не превосходит 1000.

#### Формат вывода
Нужно вывести самое большое число, которое можно составить из данных чисел.

#### Пример
<table><tbody>
  <tr>
    <td><b>Ввод</b></td>
    <td><b>Вывод</b></td>
  </tr>
  <tr>
    <td valign="top">
3<br>
15 56 2<br>

</td>
    <td valign="top">
56215<br>

</td>
  </tr>
</tbody></table>

</details>

---
