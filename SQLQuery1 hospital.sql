


CREATE TABLE Patients (
patient_id INT PRIMARY KEY,
patient_name VARCHAR(50),
age INT,
gender VARCHAR(10),
city VARCHAR(50)
);

CREATE TABLE Symptoms (
symptom_id INT PRIMARY KEY,
symptom_name VARCHAR(50)
);

CREATE TABLE Diagnoses (
diagnosis_id INT PRIMARY KEY,
diagnosis_name VARCHAR(50)
);

CREATE TABLE Visits (
visit_id INT PRIMARY KEY,
patient_id INT,
symptom_id INT,
diagnosis_id INT,
visit_date DATE,
FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
FOREIGN KEY (symptom_id) REFERENCES Symptoms(symptom_id),
FOREIGN KEY (diagnosis_id) REFERENCES Diagnoses(diagnosis_id)
);

-- Insert data into Patients table
INSERT INTO Patients (patient_id, patient_name, age, gender, city)
VALUES
(1, 'John Smith', 45, 'Male', 'Seattle'),
(2, 'Jane Doe', 32, 'Female', 'Miami'),
(3, 'Mike Johnson', 50, 'Male', 'Seattle'),
(4, 'Lisa Jones', 28, 'Female', 'Miami'),
(5, 'David Kim', 60, 'Male', 'Chicago');

-- Insert data into Symptoms table
INSERT INTO Symptoms (symptom_id, symptom_name)
VALUES
(1, 'Fever'),
(2, 'Cough'),
(3, 'Difficulty Breathing'),
(4, 'Fatigue'),
(5, 'Headache');

-- Insert data into Diagnoses table
INSERT INTO Diagnoses (diagnosis_id, diagnosis_name)
VALUES
(1, 'Common Cold'),
(2, 'Influenza'),
(3, 'Pneumonia'),
(4, 'Bronchitis'),
(5, 'COVID-19');

-- Insert data into Visits table
INSERT INTO Visits (visit_id, patient_id, symptom_id, diagnosis_id, visit_date)
VALUES
(1, 1, 1, 2, '2022-01-01'),
(2, 2, 2, 1, '2022-01-02'),
(3, 3, 3, 3, '2022-01-02'),
(4, 4, 1, 4, '2022-01-03'),
(5, 5, 2, 5, '2022-01-03'),
(6, 1, 4, 1, '2022-05-13'),
(7, 3, 4, 1, '2022-05-20'),
(8, 3, 2, 1, '2022-05-20'),
(9, 2, 1, 4, '2022-08-19'),
(10, 1, 2, 5, '2022-12-01');


select * from Patients;
select * from Symptoms;
select * from Diagnoses;
select * from Visits;

--1. Write a SQL query to retrieve all patients who have been diagnosed with COVID-19

select p.patient_id, p.patient_name,p.age,p.gender,p.city 
from Patients as p
join Visits as v
on p.patient_id=v.patient_id
join Diagnoses as d
on v.diagnosis_id=d.diagnosis_id
where d.diagnosis_name='COVID-19';


--2. Write a SQL query to retrieve the number of visits made by each patient, ordered by the number of visits in descending order
select p.patient_name ,count(p.patient_name) as noofvisits
from Patients as p 
join Visits as v on p.patient_id=v.patient_id
group by p.patient_name
order by count(p.patient_name) desc;

--3. Write a SQL query to calculate the average age of patients who have been diagnosed with Pneumonia.
select p.patient_name ,avg(p.age )as avgageofpt
from Patients as p
join Visits as v on p.patient_id=v.patient_id
join Diagnoses as d on v.diagnosis_id=d.diagnosis_id
where d.diagnosis_name='Pneumonia'
group by p.patient_name

--4. Write a SQL query to retrieve the top 3 most common symptoms among all visits.
select symptom_name from (select   top 3 s.symptom_name,count(*)as cs
from Symptoms as s
join Visits as v on s.symptom_id=v.symptom_id
group by s.symptom_name
order by count(*) desc)as sp;


--5. Write a SQL query to retrieve the patient who has the highest number of different symptoms reported.

with cte as (select  p.patient_name,s.symptom_name ,DENSE_RANK() over(partition by p.patient_name order by s.symptom_id ) as rn
from Patients as p
join Visits as v on p.patient_id=v.patient_id
join Symptoms as s on v.symptom_id=s.symptom_id
)
select cte.patient_name,count(rn) as hightest_number_ofdiffsym from cte
group by cte.patient_name
order by count(cte.rn) desc;

---or------
select  p.patient_name,count(s.symptom_name )as highestnumberofdiffsysm
from Patients as p
join Visits as v on p.patient_id=v.patient_id
join Symptoms as s on v.symptom_id=s.symptom_id
group by p.patient_name
order by count(s.symptom_name ) desc;


--6. Write a SQL query to calculate the percentage of patients who have been diagnosed with COVID-19 out of the total number of patients.
select count(*)*100/5 as covidpercentage from(select p.patient_name from Patients as p
join Visits as v on p.patient_id=v.patient_id
join Diagnoses as d  on v.diagnosis_id=d.diagnosis_id
where d.diagnosis_name='COVID-19')as sp

---or--
with covidpt as (
select distinct  p.patient_id ,p.patient_name  
from Patients as p 
join Visits as v  on p.patient_id=v.patient_id
join Diagnoses as d  on v.diagnosis_id=d.diagnosis_id
where d.diagnosis_name='COVID-19'),
totalpt as (select p.patient_id,p.patient_name  from Patients as p)
select count(covidpt.patient_id)*100/count(totalpt. patient_id)as covidpercentage
from covidpt
full join totalpt on  covidpt.patient_id=totalpt.patient_id


--7. Write a SQL query to retrieve the top 5 cities with the highest number of visits, along with the count of visits in each city.

select city,countotvisit from( select city, count(v.visit_id)as countotvisit,dense_rank() over (order by count(v.visit_id) desc)as rn
from Patients as p
join Visits as v on v.patient_id=p.patient_id
group by  city
) as temp
where rn<=5

---or----
select city, count(v.visit_id)as countotvisit
from Patients as p
join Visits as v on v.patient_id=p.patient_id
group by  city
order by count(v.visit_id) desc;

---8. Write a SQL query to find the patient who has the highest number of visits in a single day, along with the corresponding visit date
select top 1 p.patient_name,v.visit_date,count(v.visit_date)noofvisit
from Patients as p
join Visits as v on p.patient_id=v.patient_id
group by p.patient_name,v.visit_date
order by count(v.visit_date) desc

---or----
select patient_name,visit_date  from(select p.patient_name,v.visit_date,count(v.visit_id)noofvisit,rank() over (order by  count(v.visit_id) desc) rn from Patients as p
join Visits as v on p.patient_id=v.patient_id
group  by p.patient_name,v.visit_date) as temp
where rn=1

---9. Write a SQL query to retrieve the average age of patients for each diagnosis, ordered by the average age in descending order.
select d.diagnosis_name,avg(p.age)avgage from  Diagnoses as d
join Visits as v on d.diagnosis_id=v.diagnosis_id
join Patients as p on v.patient_id=p.patient_id
group by d.diagnosis_name
order by avg(p.age) desc

--10. Write a SQL query to calculate the cumulative count of visits over time, ordered by the visit date.

select  v.visit_date, count(v.visit_id) as countof_visit ,sum(count(v.visit_id)) over(order by  v.visit_date ROWS BETWEEN  unbounded preceding and current row)as cummulative
from Visits as v
group by v.visit_date
order by v.visit_date