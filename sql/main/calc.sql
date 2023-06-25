DROP TABLE IF exists bookings.results;

CREATE TABLE bookings.results (id int, response text NULL);

--1--
insert into bookings.results
select 1
  , max(t1.count_pass) 
from (select book_ref
        , count(distinct passenger_name) as count_pass
      from bookings.tickets 
      group by book_ref) as t1;

--2--
insert into bookings.results
select 2
  , count(t1.*)
from (select book_ref
        , count(*)
      from bookings.tickets
      group by book_ref 
      having count(*) > (select avg(t2.count_pass) 
			             from (select count(*) as count_pass
			                   from bookings.tickets 
                               group by book_ref) t2 ) ) t1;

--3--
insert into bookings.results
select 3
  , count((select passenger
           from (select book_ref
                   , STRING_AGG (passenger_name, ',' ORDER BY passenger_name) passenger
                 from bookings.tickets
                 where book_ref in (select book_ref
                                    from bookings.tickets
                                    group by book_ref
                                    having count(*)=5)
                 group by book_ref 
                 order by STRING_AGG (passenger_name, ',' ORDER BY passenger_name) ) t1
           group by passenger
           having count(*)>=2));

--4--
insert into bookings.results
select 4
  , book_ref || '|' || STRING_AGG ((passenger_name || '|' || contact_data), ',')
from bookings.tickets
where book_ref in (select book_ref 
                   from bookings.tickets 
                   group by book_ref 
                   having count(*)=3)
group by book_ref;

--5--
insert into bookings.results
select 5
  , max(t3.count_all)
from (select t1.book_ref
        , count(distinct t2.flight_id) as count_all 
      from bookings.tickets as t1
      left join bookings.ticket_flights as t2 on t1.ticket_no = t2.ticket_no 
      group by t1.book_ref ) t3;

--6--
insert into bookings.results
select 6
  , max(t3.count_all) 
from (select t1.book_ref
        , t1.passenger_id
        , count(distinct t2.flight_id) as count_all
        from bookings.tickets as t1
        left join bookings.ticket_flights as t2 on t1.ticket_no = t2.ticket_no 
        group by t1.book_ref
          , t1.passenger_id ) t3;

--7--
insert into bookings.results
select 7
  , max(count_all)
from (select t1.passenger_id
        , count(*) as count_all 
      from bookings.tickets as t1
      left join bookings.ticket_flights as t2 on t1.ticket_no = t2.ticket_no
      group by t1.passenger_id ) t3;

--8--
insert into bookings.results
select 8
  , t1.passenger_id|| '|' || t1.passenger_name|| '|' || t1.contact_data|| '|' || sum(amount)::varchar 
from bookings.tickets as t1
left join bookings.ticket_flights as t2 on t1.ticket_no = t2.ticket_no 
group by t1.passenger_id
  , t1.passenger_name
  , t1.contact_data
having sum(amount) = (select min(count_all) 
                      from (select t1.passenger_name
                              , sum(amount) as count_all
                            from bookings.tickets as t1
                            left join bookings.ticket_flights as t2 on t1.ticket_no = t2.ticket_no 
                            group by  t1.passenger_name) t3)
order by t1.passenger_id
  , t1.passenger_name
  , t1.contact_data;

--9--
insert into bookings.results
select 9
  , t.passenger_id|| '|' || t.passenger_name|| '|' ||  t.contact_data|| '|' ||  count_all::varchar 
from bookings.tickets as t
inner join (select passenger_id
            , sum(actual_duration) as count_all
            , rank () over (order by sum(actual_duration) desc) as rank_ 
           from bookings.tickets as t
           left join bookings.ticket_flights as tf on t.ticket_no =tf.ticket_no 
           left join bookings.flights_v as v on v.flight_id = tf.flight_id
           group by passenger_id
           having sum(actual_duration) is not null) a on t.passenger_id = a.passenger_id 
                                                       and a.rank_=1
order by t.passenger_id
  , t.passenger_name
  , t.contact_data;

--10--
insert into bookings.results
select 10
  , city 
from bookings.airports
group by city 
having count(*)>1 
order by city;

--11--
insert into bookings.results
select 11
  , departure_city
from bookings.flights_v
group by departure_city
having count(distinct arrival_city)=1
order by departure_city;

--12--
insert into bookings.results
select 12
  , t3.departure_city || '|' || t3.departure_city_2
from (select t1.departure_city
        , t2.departure_city as departure_city_2
      from bookings.routes as t1
      inner join bookings.routes as t2 on t1.departure_city <> t2.departure_city
      group by t1.departure_city
        , t2.departure_city) as t3
      left join (select t4.departure_city
                   , t4.arrival_city 
                 from bookings.routes as t4
                 group by t4.departure_city
                   , t4.arrival_city) as t5 on t3.departure_city = t5.departure_city 
                                            and t3.departure_city_2 = t5.arrival_city
where t5.departure_city is null 
  and t5.arrival_city is null 
  and t3.departure_city < t3.departure_city_2
order by t3.departure_city
  , t3.departure_city_2;

--13--
insert into bookings.results
select distinct 13
  , arrival_city 
from bookings.routes
where arrival_city not in (select arrival_city 
                           from bookings.routes 
                           where departure_city = 'Москва') 
  and arrival_city!='Москва'
order by arrival_city;

--14--
insert into bookings.results
select 14
, t1.model
from bookings.aircrafts t1 
left join bookings.flights t2 on t1.aircraft_code = t2.aircraft_code
where t2.status = 'Arrived'
group by t1.model
order by count(t1.model) desc limit 1;

--15--
insert into bookings.results
select 15
  , t2.model
from bookings.flights t1 
left join bookings.aircrafts t2 on t1.aircraft_code = t2.aircraft_code
left join bookings.ticket_flights t3 on t3.flight_id = t1.flight_id 
where t1.status = 'Arrived'
group by t2.model
order by count(*) desc limit 1;

--16--
insert into bookings.results
select 16
, (DATE_PART('day', count_all) * 24 + DATE_PART('hour', count_all)) * 60 + DATE_PART('minute',count_all)
from (select (sum(scheduled_duration) - sum(actual_duration)) as count_all  
      from bookings.flights_v where status = 'Arrived') as t1;

--17--
insert into bookings.results
select distinct 17
  , arrival_city
from bookings.flights_v
where departure_city = 'Санкт-Петербург'
  and status = 'Arrived'
  and date_trunc('day', actual_departure) = '2016-09-13';

--18--
insert into bookings.results
select distinct 18
  , flight_id || '|' || flight_no || '|' || departure_city || '|' || arrival_city
from bookings.flights_v
where flight_id = (select flight_id 
				   from bookings.ticket_flights 
				   group by flight_id 
				   order by sum(amount) desc limit 1);

--19--
insert into bookings.results
select distinct 19
  , date_trunc('day', actual_departure)
from bookings.flights_v  
where status = 'Arrived'
group by date_trunc('day', actual_departure) 
having count(*) = (select count(*)
                   from bookings.flights_v  
                   where status = 'Arrived'
                   group by date_trunc('day', actual_departure)
                   order by count(*) limit 1);

--20--
insert into bookings.results
select 20
  , avg(t1.count_all)  
from (select count(*) as count_all
        , date_trunc('day', actual_departure)
      from  bookings.flights_v 
      where departure_city = 'Москва'
        and status = 'Arrived' 
        and date_trunc('month', actual_departure) = '2016-09-01'
      group by date_trunc('day', actual_departure) ) as t1;

--21--
insert into bookings.results
select 21
  , departure_city
from bookings.flights_v
group by departure_city 
having avg(actual_duration) > '03:00:00'::interval
order by avg(actual_duration) desc limit 5;