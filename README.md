# CS2102Project

## Testing Triggers:
**All triggers are tested on pgAdmin, starting with an empty schema**
- Trigger 13) 
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
  15. `insert into CourseOffering`