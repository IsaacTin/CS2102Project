# CS2102Project

## Testing Triggers:
**All triggers are tested on pgAdmin, starting with an empty schema**
Here is how you can replicate the test for trigger 13)
1.  Add database table scheme to pgAdmin
2.  Add trigger 13 to pgAdmin
3. `insert into Customers (name, phone, address, email, number) values ('Sanders Gidley', 99820092, '78786 Steensland Park', 'sgidley0@google.co.jp', '5602250147265633');`
4. `insert into Credit_cards (number, CVV, expiry_date, from_date, cust_id) values(1234567812345678, 123, '2023-03-03', '2019-03-03', 1);`
5. `insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('ActivePackage', 50, '2021-03-22', '2021-05-05', 2);`
6. `insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('PartiallyActivePackage', 60, '2021-02-22', '2021-05-05', 0);`
7. `insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('InactivePackage', 60, '2020-03-22', '2020-05-05', 0);`
8. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 10, 1, 1234567812345678, 1);`
9. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 10, 1, 1234567812345678, 2);`
- Step 9 should fail since step 8 already added an active package. 
- This tests that only one active package can exists
10. `delete from Buys`
11. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 0, 1, 1234567812345678, 3);`
12. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 1, 1, 1234567812345678, 3);`
- Step 12 should succeed as step 11 added an inactive package, so adding another package is possible
13. `delete from Buys`
14. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 0, 1, 1234567812345678, 2);`
15. `insert into Courses(course_area_name, title, description, duration) values('Science', 'Living with Science', 'Description about science', 2);`
16. `insert into Employees(name, phone, address, email, depart_date, join_date) values('Hans Sebastian', 91234567, '98616 Petterle Lane', 'dciani1@abc.net.au', null, '2012-07-04');`
17. `insert into Rooms(location, seating_capacity) values('Everett Drive', 300);`
18. `insert into CourseOfferings(launch_date, start_date, end_date, registration_deadline, target_number_registrations, seating_capacity, fees, course_id, eid) values('2021-01-01', '2021-03-03', '2021-06-03', '2021-03-01', 300, 300, 50, 1, 1);`
19. `insert into CourseOfferingSessions(sid, start_time, end_time, rid, eid, course_id, session_date, launch_date) values(1, '15:00', '17:00', 1, 1, 1, '2021-06-03', '2021-01-01');`
  - The session date is within 6 months of the CURRENT_DATE (2021-04-07)
20. `insert into Redeems(redeems_date, buys_date, sid, course_id, launch_date, cust_id, number, package_id) values('2021-04-03', '2012-07-04', 1, 1, '2021-01-01', 1, 1234567812345678, 1);`
21. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 2, 1, 1234567812345678, 2);`
  - This should fail as we have previously inserted a partially active package in steps 13-20
22. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 0, 1, 1234567812345678, 3);`
  - This should succeed as we are adding an inactive pacakge, and there is only one partially active pacakge present
22. `insert into Buys(buys_date, num_remaining_redemptions, cust_id, number, package_id) values('2012-07-04', 2, 1, 1234567812345678, 2);`
  - This should succeed as we are adding for a different customer
  