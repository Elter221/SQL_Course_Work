# Курсовая работа по SQL: Магазин починок и запчастей(OLTP, OLAP и ETL процессы)

## Требования к pgAdmin:
   *   Имя пользователя: `postgres`
   *   Пароль: `12345`

## Шаг 1: Создание и наполнение базы OLTP

1.  Откройте файл `OLTP.sql` и запустите скрипт изображенный на фото:
    ![image](https://github.com/user-attachments/assets/0e1b17ef-98c2-48de-9c3f-45118e135ded)

    После чего нужно сменить connection на oltp_db.

2.  Запустите скрипт `OLTP.sql`.

    Должна создасться база изображенная ниже.
    
    ![image](https://github.com/user-attachments/assets/72c649d5-0820-4fae-885d-bda9fa747563)
    [Link to diagram](https://drawsql.app/teams/-1066/diagrams/oltp-cw)


4.  Откройте файл `ETL1.sql`.
    *   Укажите путь к вашим файлам `Orders.csv`, `Product_Prices.csv`, `Repairs.csv`, `Fix_prices.csv` в запросе:


    ```sql
    FROM 'Your path\Relevant.csv' DELIMITER ',' CSV HEADER;
    ```

    *   Запустите скрипт.

## Шаг 2: Создание базы OLAP

1.  Откройте файл `OLAP.sql` и запустите скрипт изображенный на фото:
    ![image](https://github.com/user-attachments/assets/1956fc83-4536-4f61-8951-834c362c4b71)

    После чего нужно сменить connection на olap_db.

2.  Запустите скрипт `OLAP.sql`.

    Должна создасться база изображенная ниже.
    ![image](https://github.com/user-attachments/assets/5451f5e9-eeba-498f-aced-260c203936f5)
    [Link to diagram](https://drawsql.app/teams/-1066/diagrams/olap-cw)


3.  Запустите скрипт `ETL2.sql`.

    * Если же у вас другой пароль от pgAdmin, то нужно изменить пароль в скрипте на ваш(можно пробить по поиску 12345, данная комбинация встречается только в коде ниже), тоже самое и с user(поиск производить по postgres)


    ```sql
    'dbname=oltp_db user=postgres password=12345 host=localhost'
    ```

## Шаг 3: Запросы для баз OLTP и OLAP

1.  Запустите запросы из файла `OLTP_Queries.csv` для анализа данных в базе OLTP (`oltp_db`). 

2.  Запустите запросы из файла `OLAP_Queries.csv` для анализа данных базы OLAP (`olap_db`).

## Шаг 4: Отчет в Power BI

1.  Откройте файл `shop_income_report.pbix` в Power BI Desktop.
    * Отчет содержит 2 страницы:
      1) Страница 'Orders' содержит данные о фактах продажи продуктов
      2) Страница 'Repairs' содержит данные о фактах прибыли с починок

## Пояснения

Данный README описывает процесс создания и наполнения баз данных OLTP (Online Transaction Processing) и OLAP (Online Analytical Processing) с использованием SQL. Процесс включает в себя создание баз данных, импорт данных из CSV файлов, перенос данных из OLTP базы в OLAP базу с помощью ETL процесса, выполнение запросов к обеим базам и чтение отчета в Power BI.

**Ключевые файлы:**

*   `OLTP.sql`: Скрипт создания структуры базы данных OLTP.
*   `ETL.sql`: Скрипты для импорта данных из CSV файлов в OLTP базу.
*   `OLAP.sql`: Скрипт создания структуры базы данных OLAP.
*   `ETL2.sql`: Скрипт для переноса данных из OLTP базы в OLAP базу.
*   `OLAP_Queries.sql`: Скрипты с запросами к OLAP базе.
*   `OLTP_Queries.sql`: Скрипты с запросами к OLTP базе.
*   `shop_income_report.pbix`: Файл проекта Power BI с отчетом о продажах магазина.
