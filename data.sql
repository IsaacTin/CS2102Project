DELETE FROM Course_packages;

DELETE FROM Rooms; -- Empty table
CALL add_room('1 Everett Drive', 33);
CALL add_room('5 Scoville Trail', 27);
CALL add_room('81 Farragut Pass', 47);
CALL add_room('880 Shelley Plaza', 48);
CALL add_room('49021 Dovetail Drive', 14);
CALL add_room('458 Menomonie Junction', 34);
CALL add_room('7271 Gulseth Terrace', 11);
CALL add_room('541 Susan Drive', 59);
CALL add_room('97 North Parkway', 42);
CALL add_room('7 Rieder Circle', 14);
CALL add_room('3682 Rigney Road', 47);
CALL add_room('18 Anzinger Junction', 42);
CALL add_room('9 Jana Park', 54);
CALL add_room('31 Shopko Trail', 52);
CALL add_room('9 Bayside Terrace', 31);
CALL add_room('123 Ilene Way', 10);
CALL add_room('62 Macpherson Lane', 45);
CALL add_room('87 Debs Drive', 16);
CALL add_room('457 Nancy Road', 20);
CALL add_room('41599 Valley Edge Center', 60);
CALL add_room('42858 Shoshone Alley', 18);
CALL add_room('015 Burrows Pass', 14);
CALL add_room('428 Delladonna Place', 58);
CALL add_room('7 Memorial Hill', 48);
CALL add_room('239 Waxwing Circle', 58);
CALL add_room('29949 Lake View Hill', 35);
CALL add_room('330 Fieldstone Way', 27);
CALL add_room('43 Toban Place', 21);
CALL add_room('364 Calypso Street', 38);
CALL add_room('323 Oriole Terrace', 24);

DELETE FROM Employees; -- Empty table
CALL add_employee('Pearla Daubeny', 94950634, '2 Pepper Wood Center', 'pdaubeny0@ask.com', 36900.20, '2005-05-13', 'manager', array ['database']);
CALL add_employee('Dagmar Ciani', 97853206, '98616 Petterle Lane', 'dciani1@abc.net.au', 1000.00, '2012-07-04', 'manager', array['information systems', 'netowrking']);
CALL add_employee('Stefa Gino', 81720714, '17500 Summit Junction', 'sgino2@storify.com', 3000.00, '2017-11-21', 'instructor', array['database']);
CALL add_employee('Dov Sicha', 97538260, '794 Packers Trail', 'dsicha3@hugedomains.com', 4000.00 , '2017-12-19', 'instructor', array['database', 'information systems']);
CALL add_employee('Dena Tancock', 89273403, '50865 Katie Parkway', 'dtancock4@shareasale.com', 4000.00, '2017-08-22', 'administrator', NULL);
CALL add_employee('Mathilde Brewett', 86719820, '77413 Meadow Vale Crossing', 'mbrewett5@mayoclinic.com', '2019-05-22', '2001-02-11');
CALL add_employee('Mathias Shivell', 98216997, '568 Oak Valley Alley', 'mshivell6@163.com', null, '2007-10-08');
CALL add_employee('Tiffie McCahill', 85175436, '5648 Corben Crossing', 'tmccahill7@printfriendly.com', null, '2004-12-29');
CALL add_employee('Orrin Jurisch', 95604288, '14 Bultman Alley', 'ojurisch8@xinhuanet.com', '2019-01-17', '2008-05-19');
CALL add_employee('Annemarie Jenny', 94439484, '385 Hooker Road', 'ajenny9@ucla.edu', null, '2006-02-10');
CALL add_employee('Menard Yate', 97870419, '3 Kinsman Terrace', 'myatea@cisco.com', null, '2002-08-08');
CALL add_employee('Wendy Guerrin', 82540806, '9 Holmberg Center', 'wguerrinb@va.gov', null, '2016-09-18');
CALL add_employee('Maurise Bowles', 94835119, '6 Cascade Point', 'mbowlesc@infoseek.co.jp', null, '2000-04-13');
CALL add_employee('Hester Lambourn', 93891393, '0527 Farmco Center', 'hlambournd@ifeng.com', '2020-04-25', '2012-11-25');
CALL add_employee('Barb Togher', 87978340, '449 Cordelia Hill', 'btoghere@bravesites.com', null, '2016-04-03');
CALL add_employee('Humfrey Bellon', 93845329, '99 Paget Court', 'hbellonf@soundcloud.com', null, '2004-12-22');
CALL add_employee('Morty Geerdts', 89248154, '87756 Swallow Hill', 'mgeerdtsg@t-online.de', null, '2017-05-11');
CALL add_employee('Darby Idle', 94394438, '10723 Rieder Plaza', 'didleh@cbc.ca', '2019-04-03', '2001-06-10');
CALL add_employee('Evyn Johnsey', 95536304, '0 Sachs Street', 'ejohnseyi@cdbaby.com', null, '2002-03-06');
CALL add_employee('Issie Krochmann', 87056825, '0153 Prentice Avenue', 'ikrochmannj@si.edu', null, '2000-02-21');
CALL add_employee('Silvester Labarre', 97835143, '41521 North Road', 'slabarrek@patch.com', '2020-10-25', '2003-09-10');
CALL add_employee('Rubie Wenman', 84131943, '9628 Green Avenue', 'rwenmanl@webeden.co.uk', null, '2005-10-04');
CALL add_employee('Godfree Kroger', 87444297, '1 Vidon Court', 'gkrogerm@fema.gov', '2020-03-29', '2005-12-10');
CALL add_employee('Evyn Trorey', 99996313, '30001 Green Junction', 'etroreyn@posterous.com', '2019-06-14', '2013-09-17');
CALL add_employee('Jaquenetta Uman', 80555086, '37819 Homewood Alley', 'jumano@wikispaces.com', '2020-07-25', '2010-06-17');
CALL add_employee('Juli Lathaye', 91584511, '9 Northridge Center', 'jlathayep@bravesites.com', null, '2010-06-27');
CALL add_employee('Matilda Coddington', 85205616, '38190 Blue Bill Park Trail', 'mcoddingtonq@wix.com', null, '2016-05-31');
CALL add_employee('Delly Ebhardt', 85452369, '2 Ridgeway Pass', 'debhardtr@amazon.co.uk', null, '2016-11-09');
CALL add_employee('Ursola Philbin', 85853736, '06 Oakridge Point', 'uphilbins@blogger.com', null, '2006-11-21');
CALL add_employee('Rosina Petroselli', 80052001, '47 Garrison Place', 'rpetrosellit@cmu.edu', null, '2001-10-28');

DELETE FROM Customers; -- Empty table
CALL add_customer('Sanders Gidley', 99820092, '78786 Steensland Park', 'sgidley0@google.co.jp', '5602250147265633', '2020-08-09', '123');
CALL add_customer('Meyer Tarzey', 87612176, '14315 Helena Park', 'mtarzey1@ucoz.ru', '5610657709090474', '2019-10-19', '321');
CALL add_customer('Webster Spaxman', 94518528, '48278 Fairfield Road', 'wspaxman2@amazon.co.uk', '5602230651814471', '2018-10-19', '892');
CALL add_customer('George Jahncke', 90421305, '14705 Atwood Court', 'gjahncke3@ustream.tv', '5602240849542561', '2017-09-09', '100');
CALL add_customer('Fritz Fawkes', 92379525, '2551 Canary Way', 'ffawkes4@samsung.com', '5610065941511739', '2026-10-19', '200');
CALL add_customer('Emmy Ridsdale', 82288253, '76513 Oak Park', 'eridsdale5@reuters.com', '5610601476073800');
CALL add_customer('Yorke Tolley', 82295969, '8113 Scoville Center', 'ytolley6@jugem.jp', '5602219467996275');
CALL add_customer('Inesita Keirl', 80989670, '52 Northwestern Junction', 'ikeirl7@surveymonkey.com', '5602251749948923');
CALL add_customer('Hayley Bowley', 80371232, '47 Ronald Regan Court', 'hbowley8@digg.com', '5602242735189440');
CALL add_customer('Dion Gebhard', 90651062, '1085 Lotheville Circle', 'dgebhard9@ftc.gov', '5602229479310241');
CALL add_customer('Kev Castro', 90769230, '92456 Londonderry Park', 'kcastroa@comcast.net', '5602258275479223');
CALL add_customer('Sanford Girardin', 97470262, '94175 Nevada Alley', 'sgirardinb@canalblog.com', '5602254153002112');
CALL add_customer('Yankee Eake', 98043174, '16 Johnson Hill', 'yeakec@skype.com', '5602248853693311');
CALL add_customer('Karyl McGreary', 92579048, '7607 Main Court', 'kmcgrearyd@soundcloud.com', '5602251427134135');
CALL add_customer('Franky Ouver', 87457533, '4286 Mayfield Crossing', 'fouvere@mozilla.org', '5602231214008650');
CALL add_customer('Pauly Agar', 87998820, '0 Aberg Plaza', 'pagarf@geocities.com', '5602215736244539');
CALL add_customer('Maribel Blabey', 89197032, '91702 Elgar Park', 'mblabeyg@webeden.co.uk', '5602210355749256');
CALL add_customer('Clo Coghlan', 96834256, '44210 Eagle Crest Drive', 'ccoghlanh@google.com.hk', '5602218964441868');
CALL add_customer('Artair Mousdall', 80476520, '345 Surrey Alley', 'amousdalli@yale.edu', '5602231452172101');
CALL add_customer('Mariette Cubbon', 92742855, '257 Arkansas Center', 'mcubbonj@lulu.com', '5602222546621815');
CALL add_customer('Spence Rault', 89689405, '94 Independence Place', 'sraultk@earthlink.net', '5602255199953572');
CALL add_customer('Cassi Vanlint', 81910481, '04 Cardinal Lane', 'cvanlintl@newyorker.com', '5602242696480846');
CALL add_customer('Benny Stockin', 95301632, '32431 Golf View Street', 'bstockinm@berkeley.edu', '5602253645715075');
CALL add_customer('Cary Meldon', 80270431, '40 Buell Drive', 'cmeldonn@goodreads.com', '5602231760069890');
CALL add_customer('Stanfield McUre', 82232366, '466 Maywood Park', 'smcureo@howstuffworks.com', '5602251005404215');
CALL add_customer('Derry Arundell', 86975680, '65 Bellgrove Street', 'darundellp@aol.com', '5602213420937658');
CALL add_customer('Rriocard Olivi', 83260682, '67 Muir Terrace', 'roliviq@ocn.ne.jp', '5602227223974999');
CALL add_customer('Cash Seabridge', 91573789, '35 Monterey Pass', 'cseabridger@addtoany.com', '5602222332369496');
CALL add_customer('Bertine Philipeaux', 94488417, '43447 Bunker Hill Street', 'bphilipeauxs@example.com', '5602239970599127');
CALL add_customer('Laraine Roeby', 98024514, '35 Russell Junction', 'lroebyt@clickbank.net', '5602234288106608');

DELETE FROM Course_packages; -- Empty table
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Diomedea irrorata', 75.35, '2021-03-22', '2021-05-05', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Nyctea scandiaca', 93.52, '2021-04-11', '2021-05-07', 5);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Larus dominicanus', 56.8, '2021-04-10', '2021-04-23', 3);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Gabianus pacificus', 69.67, '2021-03-19', '2021-04-30', 10);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Ara chloroptera', 70.25, '2021-03-24', '2021-05-03', 6);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Trachyphonus vaillantii', 86.01, '2021-04-05', '2021-04-29', 5);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Speothos vanaticus', 96.15, '2021-04-06', '2021-04-23', 1);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Tamiasciurus hudsonicus', 70.64, '2021-03-29', '2021-04-19', 10);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Ephippiorhynchus mycteria', 68.29, '2021-04-12', '2021-04-19', 2);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Pycnonotus barbatus', 55.76, '2021-03-28', '2021-04-22', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Butorides striatus', 67.49, '2021-03-24', '2021-05-04', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Canis mesomelas', 78.15, '2021-04-04', '2021-05-05', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Rhea americana', 71.19, '2021-04-09', '2021-05-04', 1);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Eumetopias jubatus', 57.73, '2021-04-05', '2021-05-07', 4);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Geochelone elegans', 52.26, '2021-03-20', '2021-04-19', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Myotis lucifugus', 57.98, '2021-04-08', '2021-05-06', 4);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Salvadora hexalepis', 73.42, '2021-04-07', '2021-05-03', 8);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Macropus giganteus', 93.51, '2021-04-03', '2021-05-03', 3);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Dicrostonyx groenlandicus', 88.71, '2021-03-29', '2021-04-24', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Macaca fuscata', 50.91, '2021-03-18', '2021-04-24', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Butorides striatus', 69.67, '2021-03-26', '2021-05-10', 5);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Leprocaulinus vipera', 58.58, '2021-04-12', '2021-04-19', 7);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Sula dactylatra', 50.32, '2021-04-03', '2021-05-06', 7);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Coluber constrictor', 53.48, '2021-04-03', '2021-04-21', 9);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Estrilda erythronotos', 70.9, '2021-04-07', '2021-04-21', 10);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Grus canadensis', 58.45, '2021-03-31', '2021-05-05', 8);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Pavo cristatus', 52.17, '2021-03-21', '2021-04-26', 8);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Papio ursinus', 59.44, '2021-03-22', '2021-04-25', 4);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Panthera pardus', 68.32, '2021-03-28', '2021-05-07', 7);
insert into Course_packages (name, price, sale_start_date, sale_end_date, num_free_registrations) values ('Pelecanus conspicillatus', 70.95, '2021-03-20', '2021-04-29', 5);

CALL 

DELETE FROM Employees; -- Empty table
CALL add_employee('Pearla Daubeny', 94950634, '2 Pepper Wood Center', 'pdaubeny0@ask.com', 36900.20, '2005-05-13', 'manager', array ['database']);
CALL add_employee('Dagmar Ciani', 97853206, '98616 Petterle Lane', 'dciani1@abc.net.au', 1000.00, '2012-07-04', 'manager', array['information systems', 'netowrking']);
CALL add_employee('Stefa Gino', 81720714, '17500 Summit Junction', 'sgino2@storify.com', 3000.00, '2017-11-21', 'instructor', array['database']);
CALL add_employee('Dov Sicha', 97538260, '794 Packers Trail', 'dsicha3@hugedomains.com', 4000.00 , '2017-12-19', 'instructor', array['database', 'information systems']);
CALL add_employee('Dena Tancock', 89273403, '50865 Katie Parkway', 'dtancock4@shareasale.com', 4000.00, '2017-08-22', 'administrator', NULL);


DELETE FROM Customers; -- Empty table
CALL add_customer('Sanders Gidley', 99820092, '78786 Steensland Park', 'sgidley0@google.co.jp', '5602250147265633', '2020-08-09', '123');
CALL add_customer('Meyer Tarzey', 87612176, '14315 Helena Park', 'mtarzey1@ucoz.ru', '5610657709090474', '2019-10-19', '321');
CALL add_customer('Webster Spaxman', 94518528, '48278 Fairfield Road', 'wspaxman2@amazon.co.uk', '5602230651814471', '2018-10-19', '892');
CALL add_customer('George Jahncke', 90421305, '14705 Atwood Court', 'gjahncke3@ustream.tv', '5602240849542561', '2017-09-09', '100');
CALL add_customer('Fritz Fawkes', 92379525, '2551 Canary Way', 'ffawkes4@samsung.com', '5610065941511739', '2026-10-19', '200');

CALL update_credit_card(1, '8502250147265633', '2040-09-08', '900');


CALL add_course('database test', 'test database', 'database', 2);
CALL add_course('information systems test', 'test information systems', 'information systems', 1);
CALL add_course('nodatabase test', 'test nodatabase', 'Nodatabase', 2);

select find_instructors(4, '2020-10-10', '09:00:00');
select get_available_instructors(4, '2020-10-10', '2020-10-13');

select get_available_rooms('2020-12-11', '2020-12-13');
CALL add_course_offering(4, 80.00, '2023-10-15', '2023-10-01',10, 100, array ['2023-11-15', '2023-11-17']::DATE[], array ['09:00:00', '14:00:00']::TIME, array [1 , 2]);
