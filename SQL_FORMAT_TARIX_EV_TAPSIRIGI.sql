-- Task 1
SELECT FIRST_NAME || ' ' || UPPER(LAST_NAME)           AS TAM_AD,
       SUBSTR(FIRST_NAME, 1, 1) || '. ' || LAST_NAME   AS QISA_AD,
       LOWER(EMAIL) || '@company.com'                  AS EMAIL
FROM HR.EMPLOYEES
ORDER BY LAST_NAME;


-- Task 2
-- ORDER BY MAAS DESC yazsaq, səhv sıralanır, çünki MAAS TO_CHAR-ın nəticəsidir, yəni mətndir.
-- Mətn ilk simvola görə sıralanır: '9,000 AZN' '24,000 AZN'-dən yuxarı çıxır, çünki '9' > '2'.
-- Ona görə rəqəmin özünə görə sıralayırıq: ORDER BY SALARY DESC.
SELECT FIRST_NAME,
       TO_CHAR(SALARY, 'FM99,999') || ' AZN'   AS MAAS,
       TO_CHAR(SALARY * 12, 'FM999,999.00')    AS ILLIK_MAAS
FROM HR.EMPLOYEES
ORDER BY SALARY DESC;


-- Task 3
SELECT FIRST_NAME,
       TO_CHAR(HIRE_DATE, 'DD.MM.YYYY')   AS ISE_GIRIS,
       EXTRACT(YEAR FROM HIRE_DATE)       AS IL,
       TO_CHAR(HIRE_DATE, 'FMMonth')      AS AY_ADI,
       TO_CHAR(HIRE_DATE, 'FMDay')        AS HEFTE_GUNU
FROM HR.EMPLOYEES
ORDER BY HIRE_DATE;


-- Task 4
SELECT FIRST_NAME || ' ' || LAST_NAME                              AS ISCI,
       TO_CHAR(HIRE_DATE, 'FMDD Month YYYY')                       AS ISE_GIRIS,
       TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) || ' il ' ||
       MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)), 12) || ' ay' AS STAJ
FROM HR.EMPLOYEES
ORDER BY HIRE_DATE;


-- Task 5 a)
SELECT FIRST_NAME,
       HIRE_DATE,
       ADD_MONTHS(HIRE_DATE, 3)        AS SINAQ_BITIR,
       LAST_DAY(HIRE_DATE)             AS ILK_MAAS_GUNU,
       LAST_DAY(HIRE_DATE) - HIRE_DATE AS MAASA_QALAN_GUN
FROM HR.EMPLOYEES;

-- Task 5 b)
-- Nəticə 31.05.2025 çıxdı, 28.05.2025 yox.
-- Səbəb: 28.02.2025 fevralın son günüdür (2025 uzun il deyil).
-- ADD_MONTHS-in qaydası: başlanğıc tarix ayın son günüdürsə, nəticə də ayın son günü olur.
-- Mayın son günü isə 31-dir.
SELECT ADD_MONTHS(TO_DATE('28.02.2025', 'DD.MM.YYYY'), 3) AS NETICE
FROM DUAL;


-- Task 6
-- Səhv 1: CONCAT yalnız 2 dəyər qəbul edir, burada 3 idi. || ilə əvəz etdim.
-- Səhv 2: NVL-də rəqəm ilə mətn qarışırdı. Əvvəl TO_CHAR ilə mətnə çevirdim.
--         'FM0.00' formatı ilə .2 yox, 0.20 görünür.
-- Səhv 3: MM formatı martı '03' kimi qaytarır, '3' yox. Xəta vermir, nəticə boş çıxırdı.
SELECT FIRST_NAME || ' ' || LAST_NAME || ', komissiya: ' ||
       NVL(TO_CHAR(COMMISSION_PCT, 'FM0.00'), 'yoxdur') AS MELUMAT
FROM HR.EMPLOYEES
WHERE TO_CHAR(HIRE_DATE, 'MM') = '03';


-- Task 7
-- ORDER BY AY yazsaq, sıra əlifba ilə gedərdi: April, August, December, February ...
-- Çünki AY mətndir (ayın adı) və mətn hərflərə görə sıralanır, təqvimə görə yox.
-- Təqvim sırası üçün AY_NO-ya görə sıraladım: '01', '02', ... '12'.
SELECT TO_CHAR(HIRE_DATE, 'MM')      AS AY_NO,
       TO_CHAR(HIRE_DATE, 'FMMonth') AS AY,
       COUNT(*)                      AS ISCI_SAYI
FROM HR.EMPLOYEES
GROUP BY TO_CHAR(HIRE_DATE, 'MM'), TO_CHAR(HIRE_DATE, 'FMMonth')
ORDER BY AY_NO;


--TASK 8
SELECT EMPLOYEE_ID,
    LOWER(SUBSTR(FIRST_NAME,1,1)|| LAST_NAME)|| LPAD(EMPLOYEE_ID,4,0) AS LOGIN,
    REPLACE(PHONE_NUMBER,'.','-') AS TELEFON
FROM HR.EMPLOYEES
WHERE LENGTH(LAST_NAME)>=7
ORDER BY LOGIN;

--TASK 9
-- MIN(TO_CHAR(HIRE_DATE, 'DD.MM.YYYY')) yazsaq, səhv olar, çünki əvvəl tarix mətnə çevrilir,
-- sonra MIN mətnlərin ən kiçiyini tapır. Mətn ilk simvola, yəni GÜNƏ görə müqayisə olunur.
-- Məsələn, '03.12.2005' '25.01.2005'-dən kiçik sayılır, çünki '0' < '2'.
-- Halbuki ən erkən tarix 25 yanvardır. Düzgün yol: əvvəl MIN(HIRE_DATE), sonra TO_CHAR.
SELECT EXTRACT(YEAR FROM HIRE_DATE)              AS IL,
       COUNT(*)                                  AS ISCI_SAYI,
       TO_CHAR(MIN(HIRE_DATE), 'DD.MM.YYYY')     AS ILK_TARIX,
       TO_CHAR(MAX(HIRE_DATE), 'DD.MM.YYYY')     AS SON_TARIX,
       TO_CHAR(AVG(SALARY), 'FM99,999.00')       AS ORTA_MAAS
FROM HR.EMPLOYEES
GROUP BY EXTRACT(YEAR FROM HIRE_DATE)
ORDER BY IL;


-- Task 10 a)
-- CASE-in içində TO_CHAR(HIRE_DATE, 'DAY') = 'SATURDAY' yazsaq, heç kim 'Hefte sonu' olmaz.
-- Səbəb: DAY formatı gün adını 9 simvola qədər boşluqla doldurur: 'SATURDAY ' (sonda 1 boşluq).
-- 'SATURDAY ' = 'SATURDAY' doğru deyil, ona görə hamı 'Is gunu' çıxır. Xəta vermir.
-- Həll: FMDAY yazmaq və ya qısa formatdan (DY) istifadə etmək, onda boşluq olmur.
SELECT FIRST_NAME,
       TO_CHAR(HIRE_DATE, 'Dy, DD.MM.YYYY') AS ISE_GIRIS,
       CASE
           WHEN TO_CHAR(HIRE_DATE, 'DY') IN ('SAT', 'SUN') THEN 'Hefte sonu'
           ELSE 'Is gunu'
       END AS GUN_NOVU
FROM HR.EMPLOYEES;

-- Task 10 b)
SELECT TO_CHAR(HIRE_DATE, 'FMDay') AS GUN,
       COUNT(*)                    AS ISCI_SAYI
FROM HR.EMPLOYEES
GROUP BY TO_CHAR(HIRE_DATE, 'FMDay')
ORDER BY ISCI_SAYI DESC;
