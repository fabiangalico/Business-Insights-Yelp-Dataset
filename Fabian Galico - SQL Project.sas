LIBNAME yelp "C:\Users\fgalicojustitz\Desktop\SQL-Tableau\Individual Project\Data and Instructions";

*Create the basetable from business table, with a new column with labels for different stars ranges;
PROC SQL;
CREATE TABLE yelp.business_basetable AS
SELECT *, case when stars between 1 and 2.99 then 'Bad'
		  when stars between 3 and 3.49 then 'Regular'
		  when stars between 3.5 and 3.99 then 'Good'
		  when stars between 4 and 4.49 then 'Very Good'
    else 'Excellent' end as Stars_Label
FROM yelp.yelp_business;
QUIT;

*Create a new column with labels for different review count ranges;
PROC SQL;
CREATE TABLE yelp.business_basetable AS
SELECT *, case when review_count between 1 and 9 then '[1-9]'
		  when review_count between 10 and 29 then '[10-29]'
		  when review_count between 30 and 100 then '[30-100]'
    else '>100' end as Rev_Count_Label
FROM yelp.business_basetable;
QUIT;

PROC SQL;
CREATE TABLE yelp.business_basetable AS
SELECT *, case when is_open = 1 then 'Yes'
    else 'No' end as Open
FROM yelp.business_basetable;
QUIT;


*Create a new column with specific categories for businesses;
PROC SQL;
CREATE TABLE yelp.business_basetable AS
SELECT *, case when categories contains('Chinese') then 'Chinese'
	when categories contains('Vietnamese') then 'Vietnamese'
	when categories contains('Indian') then 'Indian' 
	when categories contains('Mexican') then 'Mexican'
	when categories contains('Restaurants') then 'Restaurant'
	when categories contains('Automotive') then 'Cars'
	when categories contains('Fast Food') then 'Fast Food'
	when categories contains('Education') then 'Education'
	when categories contains('Bars') then 'Bars'
	when categories contains('Health') then 'Health'
	when categories contains('Pet') then 'Pets'
	when categories contains('Entertainment') then 'Entertainment'
	when categories contains('Services') then 'Services'
	when categories contains('Tobacco') then 'Tobacco'
	when categories contains('Cleaning') then 'Cleaning'
	when categories contains('Bakeries') then 'Bakeries'
	when categories contains('Pizza') then 'Pizza'
	when categories contains('Korean') then 'Korean'
	when categories contains('Japanese') then 'Japanese'
	when categories contains('Bakeries') then 'Bakeries'
	when categories contains('Shopping') then 'Shopping'
	when categories contains('Coffee') then 'Coffee'
	when categories contains('Beauty') then 'Beauty'
	when categories contains('Fitness') then 'Fitness'
    else 'Other' end as Category
FROM yelp.business_basetable;
QUIT;

*Create new columns with the amount of photos per business per label;
PROC SQL;
CREATE TABLE yelp.business_basetable AS 
SELECT *
FROM  yelp.business_basetable as b LEFT JOIN (select business_id, count(*) as Photos_Inside
											  from yelp.yelp_photo
											  where label contains('inside')
											  group by business_id) as i 
								ON b.business_id = i.business_id
							LEFT JOIN (select business_id, count(*) as Photos_Outside
									   from yelp.yelp_photo
									   where label contains('outside')
									   group by business_id) as o 
							ON b.business_id = o.business_id
							LEFT JOIN (select business_id, count(*) as Photos_Food
									   from yelp.yelp_photo
									   where label contains('food')
									   group by business_id) as f
							ON b.business_id = f.business_id
							LEFT JOIN (select business_id, count(*) as Photos_Drink
									   from yelp.yelp_photo
									   where label contains('drink')
									   group by business_id) as d
							ON b.business_id  = d.business_id
							LEFT JOIN (select business_id, count(*) as Photos_Menu
									   from yelp.yelp_photo
									   where label contains('menu')
									   group by business_id) as m
							ON b.business_id  = m.business_id
							LEFT JOIN (select business_id, count(*) as Photos_Count
									   from yelp.yelp_photo
									   group by business_id) as c
							ON b.business_id  = c.business_id;
QUIT;

*Create a new table with total checkins per day, weekdays and weekend (executed on SAS Enterprise 7.1);
DATA yelp.checkin (KEEP = business_id Checkin_Monday Checkin_Tuesday Checkin_Wednesday Checkin_Thursday Checkin_Friday Checkin_Saturday Checkin_Sunday Checkin_Weekdays Checkin_Weekend Checkin_Total);
SET yelp.yelp_checkin;
Checkin_Monday = sum(OF Mon:);
Checkin_Tuesday = sum(OF Tue:);
Checkin_Wednesday = sum(OF Wed:);
Checkin_Thursday = sum(OF Thu:);
Checkin_Friday = sum(OF Fri:);
Checkin_Saturday = sum(OF Sat:);
Checkin_Sunday = sum(OF Sun:);
Checkin_Weekdays = sum(Checkin_Monday, Checkin_Tuesday, Checkin_Wednesday, Checkin_Thursday, Checkin_Friday);
Checkin_Weekend = sum(Checkin_Saturday, Checkin_Sunday);
Checkin_Total = sum(Checkin_Weekdays, Checkin_Weekend);
RUN;

*convert checkin table to excel file;
PROC EXPORT DATA = yelp.Checkin OUTFILE = "C:\Users\fgalicojustitz\Desktop\SQL-Tableau\Individual Project\Data and Instructions\checkin.xlsx" DBMS = xlsx REPLACE; 

*Merge basetable with checkin table;
PROC SQL;
CREATE TABLE yelp.business_basetable AS
SELECT *
FROM yelp.business_basetable as b LEFT JOIN yelp.checkin as c
ON b.business_id = c.business_id;
QUIT;

*Merge users and reviews table with the basetable, creating an intermediate table that joins users with reviews;
PROC SQL; 
CREATE TABLE yelp.business_basetable AS
SELECT *
FROM yelp.business_basetable as b LEFT JOIN 
				( select business_id, ROUND(avg(useful), 0.1) as Avg_Rev_Useful, ROUND(avg(User_Avg_Stars), 0.1) as Users_Avg_Stars, 
						 ROUND(avg(User_Rev_Count), 0.1) as Users_Rev_Count, ROUND(avg(User_Useful), 0.1) as Avg_User_Useful,
						 count(distinct user_id) as Nr_Users
	  			  from (select r.review_id, r.user_id, r.business_id, r.stars, r.date, r.useful,
	   						   u.average_stars as User_Avg_Stars, u.review_count as User_Rev_Count, u.useful as User_Useful
						from yelp.yelp_review2 as r, yelp.yelp_user2 as u
						where r.user_id = u.user_id)
				  group by business_id) as ru
ON b.business_id = ru.business_id;
QUIT;

*drop day hours;
PROC SQL;
ALTER TABLE yelp.business_basetable
DROP Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday;
Run;




