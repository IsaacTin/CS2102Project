DELETE FROM Course_packages; -- Empty table
-- alternate way: CALL add_course_package('DiomedeaLALLAA irrorata',9, '2021-03-22', '2021-05-05',  75.35);
CALL add_course_package('Nyctea scandiaca', 5, '2021-04-11', '2021-05-07', 93.52);
CALL add_course_package('Larus dominicanus', 3, '2021-04-10', '2021-04-23', 56.89);
CALL add_course_package('Gabianus pacificus', 1, '2021-03-19', '2021-04-30', 69.67);
CALL add_course_package('Ara chloroptera', 6, '2021-03-24', '2021-05-03', 70.25);
CALL add_course_package('Trachyphonus vaillantii', 5, '2021-04-05', '2021-04-29', 86.01);
CALL add_course_package('Diomedea irrorata', 9, '2021-03-22', '2021-05-05', 75.35);
CALL add_course_package('Speothos vanaticus', 1, '2021-04-06', '2021-04-23', 96.15);
CALL add_course_package('Tamiasciurus hudsonicus', 1, '2021-03-29', '2021-04-19', 70.64);
CALL add_course_package('Ephippiorhynchus mycteria', 2, '2021-04-12', '2021-04-19', 68.29);
CALL add_course_package('Pycnonotus barbatus', 9, '2021-03-28', '2021-04-22', 55.76);
CALL add_course_package('Canis mesomelas', 9, '2021-04-04', '2021-05-05', 78.15);
CALL add_course_package('Butorides striatus', 9, '2021-03-24', '2021-05-04', 67.49);
CALL add_course_package('Rhea americana', 1, '2021-04-09', '2021-05-04', 71.19);
CALL add_course_package('Eumetopias jubatus', 4, '2021-04-05', '2021-05-07', 57.73);
CALL add_course_package('Geochelone elegans', 9, '2021-03-20', '2021-04-19', 52.26);
CALL add_course_package('Myotis lucifugus', 4, '2021-04-08', '2021-05-06', 57.98);
CALL add_course_package('Salvadora hexalepis', 8, '2021-04-07', '2021-05-03', 73.42);
CALL add_course_package('Macropus giganteus', 3, '2021-04-03', '2021-05-03', 93.51);
CALL add_course_package('Dicrostonyx groenlandicus', 9, '2021-03-29', '2021-04-24', 88.71);
CALL add_course_package('Macaca fuscata', 9, '2021-03-18', '2021-04-24', 50.91);
CALL add_course_package('Butorides striatus', 5, '2021-03-26', '2021-05-10', 69.67);
CALL add_course_package('Leprocaulinus vipera', 7, '2021-04-12', '2021-04-19', 58.58);
CALL add_course_package('Sula dactylatra', 7, '2021-04-03', '2021-05-06', 50.32);
CALL add_course_package('Coluber constrictor', 9, '2021-04-03', '2021-04-21', 53.48);
CALL add_course_package('Estrilda erythronotos', 1, '2021-04-07', '2021-04-21', 70.90);
CALL add_course_package('Grus canadensis', 8, '2021-03-31', '2021-05-05', 58.45);
CALL add_course_package('Pavo cristatus', 8, '2021-03-21', '2021-04-26', 52.17);
CALL add_course_package('Papio ursinus', 4, '2021-03-22', '2021-04-25', 59.44);
CALL add_course_package('Panthera pardus', 7, '2021-03-28', '2021-05-07', 68.32);
CALL add_course_package('Pelecanus conspicillatus', 5, '2021-03-20', '2021-04-29', 70.95);

DELETE FROM Rooms; -- Empty table
CALL add_room('1 Everett Drive', 33);
CALL add_room('5 Scoville Trail', 1);
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
-- Managers
CALL add_employee('Pearla Daubeny', 94950634, '2 Pepper Wood Center', 'pdaubeny0@ask.com', 36900.20, '2005-05-13', 'manager', array ['A']);
CALL add_employee('Dagmar Ciani', 97853206, '98616 Petterle Lane', 'dciani1@abc.net.au', 1000.20, '2012-07-04', 'manager', array['B']);
CALL add_employee('Hester Lambourn', 93891393, '0527 Farmco Center', 'hlambournd@ifeng.com', 10000.10, '2017-09-08', 'manager', array['C']);
CALL add_employee('Barb Togher', 87978340, '449 Cordelia Hill', 'btoghere@bravesites.com', 20000.00, '2017-09-08', 'manager', array['D']);
CALL add_employee('Humfrey Bellon', 93845329, '99 Paget Court', 'hbellonf@soundcloud.com', 30000.05, '2017-09-08', 'manager', array['E']);
CALL add_employee('Morty Geerdts', 89248154, '87756 Swallow Hill', 'mgeerdtsg@t-online.de', 6969.69, '2017-09-08', 'manager', array['F']);
CALL add_employee('Darby Idle', 94394438, '10723 Rieder Plaza', 'didleh@cbc.ca', 23000.00, '2017-09-08', 'manager', array['G']);
CALL add_employee('Evyn Johnsey', 95536304, '0 Sachs Street', 'ejohnseyi@cdbaby.com', 11000.00, '2017-09-08', 'manager', array['H']);
CALL add_employee('Issie Krochmann', 87056825, '0153 Prentice Avenue', 'ikrochmannj@si.edu', 21000.00, '2017-09-08', 'manager', array['I', 'J']);
CALL add_employee('Silvester Labarre', 97835143, '41521 North Road', 'slabarrek@patch.com', 1010.10, '2017-09-08', 'manager', array['K', 'L', 'M']);

-- Instructors - $100 for salary input means part-time employee
CALL add_employee('Stefa Gino', 81720714, '17500 Summit Junction', 'sgino2@storify.com', 10.00, '2017-11-21', 'instructor', array['A', 'B', 'C']);
CALL add_employee('Dov Sicha', 97538260, '794 Packers Trail', 'dsicha3@hugedomains.com', 20.00 , '2018-12-19', 'instructor', array['D', 'E', 'F']);
CALL add_employee('Mathilde Brewett', 86719820, '77413 Meadow Vale Crossing', 'mbrewett5@mayoclinic.com', 30.00, '2017-01-01', 'instructor', array['G', 'H', 'I']);
CALL add_employee('Mathias Shivell', 98216997, '568 Oak Valley Alley', 'mshivell6@163.com', 40.00, '2017-01-02', 'instructor', array['J', 'K', 'L']);
CALL add_employee('Tiffie McCahill', 85175436, '5648 Corben Crossing', 'tmccahill7@printfriendly.com', 50.00, '2017-11-03', 'instructor', array['M', 'A']);
CALL add_employee('Orrin Jurisch', 95604288, '14 Bultman Alley', 'ojurisch8@xinhuanet.com', 60.00, '2017-11-04', 'instructor', array['B', 'C', 'D']);
CALL add_employee('Annemarie Jenny', 94439484, '385 Hooker Road', 'ajenny9@ucla.edu', 70.00, '2017-11-05', 'instructor', array['E', 'F','G']);
CALL add_employee('Menard Yate', 97870419, '3 Kinsman Terrace', 'myatea@cisco.com', 80.00, '2017-11-06', 'instructor', array['H']);
CALL add_employee('Wendy Guerrin', 82540806, '9 Holmberg Center', 'wguerrinb@va.gov', 90.00, '2017-11-07', 'instructor', array['I']);
CALL add_employee('Maurise Bowles', 94835119, '6 Cascade Point', 'mbowlesc@infoseek.co.jp', 99.00, '2017-11-08', 'instructor', array['J']);
-- Instructors - full time, where salary input is > 100
CALL add_employee('Godfree Kroger', 87444297, '1 Vidon Court', 'gkrogerm@fema.gov', 5600.00, '2018-01-01', 'instructor', array['C']);
CALL add_employee('Evyn Trorey', 99996313, '30001 Green Junction', 'etroreyn@posterous.com', 5000.00, '2018-01-01', 'instructor', array['D']);
CALL add_employee('Jaquenetta Uman', 80555086, '37819 Homewood Alley', 'jumano@wikispaces.com', 5001.00, '2018-01-01', 'instructor', array['E']);
CALL add_employee('Juli Lathaye', 91584511, '9 Northridge Center', 'jlathayep@bravesites.com', 5002.00, '2018-01-01', 'instructor', array['F']);
CALL add_employee('Matilda Coddington', 85205616, '38190 Blue Bill Park Trail', 'mcoddingtonq@wix.com', 5003.00, '2018-01-01', 'instructor', array['G']);
CALL add_employee('Delly Ebhardt', 85452369, '2 Ridgeway Pass', 'debhardtr@amazon.co.uk', 5004.00, '2018-01-01', 'instructor', array['H']);
CALL add_employee('Ursola Philbin', 85853736, '06 Oakridge Point', 'uphilbins@blogger.com', 5005.00, '2018-01-01', 'instructor', array['I']);
CALL add_employee('Rosina Petroselli', 80052001, '47 Garrison Place', 'rpetrosellit@cmu.edu', 5006.00, '2018-01-01', 'instructor', array['J']);
CALL add_employee('Dena Tancock', 89273403, '50865 Katie Parkway', 'dtancock4@shareasale.com', 5007.00, '2018-01-01', 'instructor', array['K']);
CALL add_employee('Rubie Wenman', 84131943, '9628 Green Avenue', 'rwenmanl@webeden.co.uk', 5008.00, '2005-10-04', 'instructor', array['A', 'B', 'C']);

-- Administrators
CALL add_employee('Dexter Leverson', 83158434, '03973 Sheridan Road', 'dleverson1@wikimedia.org', 4356.25, '2019-12-28', 'administrator',NULL);
CALL add_employee('Vita Espadero', 82052377, '4 Cherokee Pass', 'vespadero2@tripadvisor.com', 3536.69, '2020-06-02', 'administrator', NULL);
CALL add_employee('Maurene Gooddie', 84661470, '284 Lyons Circle', 'mgooddie3@ycombinator.com', 3618.55, '2020-05-28', 'administrator', NULL);
CALL add_employee('Gwendolen Blaszczynski', 88356105, '94 Dwight Lane', 'gblaszczynski0@goodreads.com', 4384.3, '2019-12-14', 'administrator', NULL);
CALL add_employee('Justinn Pasque', 85178219, '7246 Ludington Circle', 'jpasque4@wordpress.org', 4333.2, '2020-06-04', 'administrator', NULL);
CALL add_employee('Caresa Antham', 86488030, '9 Loeprich Alley', 'cantham5@baidu.com', 4465.97, '2021-01-16', 'administrator', NULL);
CALL add_employee('Sheri Gilbee', 82766482, '980 Schurz Plaza', 'sgilbee6@ftc.gov', 4067.96, '2020-03-02', 'administrator', NULL);
CALL add_employee('Guenna Burland', 82875256, '6 Declaration Avenue', 'gburland7@vistaprint.com', 3774.44, '2020-04-14', 'administrator', NULL);
CALL add_employee('Eugenia Smitten', 88305276, '26 Eagan Trail', 'esmitten8@marriott.com', 3689.06, '2020-09-24', 'administrator', NULL);
CALL add_employee('Taber Gruszczak', 81507433, '0 Roth Park', 'tgruszczak9@ning.com', 3691.27, '2020-02-23', 'administrator', NULL);

-- Full_time_Emp taken into consideration from add_employee function
-- Part_time_Emp taken into consideration from add_employee function
-- Managers taken into consideration from add_employee function
-- CourseAreaManaged taken into consideration from add_employee function
-- Instructors taken into consideration from add_employee function
-- Specializes taken into consideration from add_employee function
-- Part_time_instructors taken into consideration from add_employee function
-- Full_time_instructors taken into consideration from add_employee function

DELETE FROM Courses;
CALL add_course('Fiveclub', 'Toxic eff of harmful algae and algae toxins, slf-hrm, subs', 'A', 1);
CALL add_course('Buzzbean', 'Melanocytic nevi of right upper limb, including shoulder', 'B', 2);
CALL add_course('Izio', 'Age-rel osteopor w current path fracture, unsp femur, init', 'C', 3);
CALL add_course('Npath', 'Nondisp midcervical fx l femur, subs for clos fx w nonunion', 'D', 2);
CALL add_course('Blogtags', 'Oth injuries of left shoulder and upper arm, init encntr', 'E', 1);
CALL add_course('Buzzshare', 'Unsp intracap fx r femr, subs for opn fx type I/2 w malunion', 'F', 2);
CALL add_course('Aimbo', 'Displ commnt fx shaft of ulna, r arm, 7thQ', 'A', 3);
CALL add_course('Trilia', 'Enlargement of left orbit', 'B', 3);
CALL add_course('Quimba', 'Underdosing of calcium-channel blockers', 'C', 1);
CALL add_course('Midel', 'Other fracture of shaft of radius, left arm', 'H', 2);
CALL add_course('Twitterworks', 'Malformation of placenta, unspecified, first trimester', 'J', 3);
CALL add_course('Geba', 'Injury to barefoot water-skier, sequela', 'M', 2);
CALL add_course('Gabvine', 'Animal-rider injured in collision w 2/3-whl mv', 'I', 1);
CALL add_course('Trilith', 'Superficial foreign body of other part of head, init encntr', 'G', 2);
CALL add_course('Eare', 'Nondisplaced oth extrartic fracture of l calcaneus, sequela', 'K', 3);

DELETE FROM Customers; -- Empty table
CALL add_customer('Sanders Gidley', 99820092, '78786 Steensland Park', 'sgidley0@google.co.jp', '5602250147265633', '2020-08-09', '001');
CALL add_customer('Meyer Tarzey', 87612176, '14315 Helena Park', 'mtarzey1@ucoz.ru', '5610657709090474', '2019-10-19', '002');
CALL add_customer('Webster Spaxman', 94518528, '48278 Fairfield Road', 'wspaxman2@amazon.co.uk', '5602230651814471', '2018-10-19', '892');
CALL add_customer('George Jahncke', 90421305, '14705 Atwood Court', 'gjahncke3@ustream.tv', '5602240849542561', '2017-09-09', '100');
CALL add_customer('Fritz Fawkes', 92379525, '2551 Canary Way', 'ffawkes4@samsung.com', '5610065941511739', '2026-10-19', '200');
CALL add_customer('Emmy Ridsdale', 82288253, '76513 Oak Park', 'eridsdale5@reuters.com', '5610601476073800', '2021-11-19', '234');
CALL add_customer('Yorke Tolley', 82295969, '8113 Scoville Center', 'ytolley6@jugem.jp', '5602219467996275', '2022-11-19', '224');
CALL add_customer('Inesita Keirl', 80989670, '52 Northwestern Junction', 'ikeirl7@surveymonkey.com', '5602251749948923', '2023-11-19', '111');
CALL add_customer('Hayley Bowley', 80371232, '47 Ronald Regan Court', 'hbowley8@digg.com', '5602242735189440', '2023-12-19', '112');
CALL add_customer('Dion Gebhard', 90651062, '1085 Lotheville Circle', 'dgebhard9@ftc.gov', '5602229479310241', '2023-01-19', '113');
CALL add_customer('Kev Castro', 90769230, '92456 Londonderry Park', 'kcastroa@comcast.net', '5602258275479223', '2023-02-19', '114');
CALL add_customer('Sanford Girardin', 97470262, '94175 Nevada Alley', 'sgirardinb@canalblog.com', '5602254153002112', '2023-03-19', '115');
CALL add_customer('Yankee Eake', 98043174, '16 Johnson Hill', 'yeakec@skype.com', '5602248853693311', '2023-04-19', '116');
CALL add_customer('Karyl McGreary', 92579048, '7607 Main Court', 'kmcgrearyd@soundcloud.com', '5602251427134135', '2023-05-19', '117');
CALL add_customer('Franky Ouver', 87457533, '4286 Mayfield Crossing', 'fouvere@mozilla.org', '5602231214008650', '2023-06-19', '118');
CALL add_customer('Pauly Agar', 87998820, '0 Aberg Plaza', 'pagarf@geocities.com', '5602215736244539', '2023-07-19', '119');
CALL add_customer('Maribel Blabey', 89197032, '91702 Elgar Park', 'mblabeyg@webeden.co.uk', '5602210355749256', '2023-08-19', '120');
CALL add_customer('Clo Coghlan', 96834256, '44210 Eagle Crest Drive', 'ccoghlanh@google.com.hk', '5602218964441868', '2023-09-19', '121');
CALL add_customer('Artair Mousdall', 80476520, '345 Surrey Alley', 'amousdalli@yale.edu', '5602231452172101', '2023-10-19', '122');
CALL add_customer('Mariette Cubbon', 92742855, '257 Arkansas Center', 'mcubbonj@lulu.com', '5602222546621815', '2023-11-19', '125');
CALL add_customer('Spence Rault', 89689405, '94 Independence Place', 'sraultk@earthlink.net', '5602255199953572', '2023-12-01', '126');
CALL add_customer('Cassi Vanlint', 81910481, '04 Cardinal Lane', 'cvanlintl@newyorker.com', '5602242696480846', '2023-12-02', '127');
CALL add_customer('Benny Stockin', 95301632, '32431 Golf View Street', 'bstockinm@berkeley.edu', '5602253645715075', '2023-12-03', '128');
CALL add_customer('Cary Meldon', 80270431, '40 Buell Drive', 'cmeldonn@goodreads.com', '5602231760069890', '2023-12-04', '129');
CALL add_customer('Stanfield McUre', 82232366, '466 Maywood Park', 'smcureo@howstuffworks.com', '5602251005404215', '2023-12-05', '130');
CALL add_customer('Derry Arundell', 86975680, '65 Bellgrove Street', 'darundellp@aol.com', '5602213420937658', '2023-12-06', '131');
CALL add_customer('Rriocard Olivi', 83260682, '67 Muir Terrace', 'roliviq@ocn.ne.jp', '5602227223974999', '2023-12-07', '132');
CALL add_customer('Cash Seabridge', 91573789, '35 Monterey Pass', 'cseabridger@addtoany.com', '5602222332369496', '2023-12-08', '133');
CALL add_customer('Bertine Philipeaux', 94488417, '43447 Bunker Hill Street', 'bphilipeauxs@example.com', '5602239970599127', '2023-12-09', '134');
CALL add_customer('Laraine Roeby', 98024514, '35 Russell Junction', 'lroebyt@clickbank.net', '5602234288106608', '2023-12-10', '135');

-- Credit_cards taken into consideration from add_employee function

DELETE FROM Buys;
CALL buy_course_package(1, 1);
CALL buy_course_package(16, 1);
CALL buy_course_package(17, 1);

CALL buy_course_package(2, 2);
CALL buy_course_package(18, 2);
CALL buy_course_package(19, 2);


CALL buy_course_package(3, 3);
CALL buy_course_package(20, 3);
CALL buy_course_package(21, 3);
CALL buy_course_package(22, 3);

CALL buy_course_package(4, 4);
CALL buy_course_package(5, 5);
CALL buy_course_package(6, 6);
CALL buy_course_package(7, 7);
CALL buy_course_package(8, 8);
CALL buy_course_package(9, 9);
CALL buy_course_package(10, 10);
CALL buy_course_package(11, 11);
CALL buy_course_package(12, 12);
CALL buy_course_package(13, 13);
CALL buy_course_package(14, 14);
CALL buy_course_package(15, 15);
CALL buy_course_package(23, 8);
CALL buy_course_package(24, 9);
CALL buy_course_package(25, 10);
CALL buy_course_package(26, 11);
CALL buy_course_package(27, 12);
CALL buy_course_package(28, 13);
CALL buy_course_package(29, 14);
CALL buy_course_package(30, 15);

-- Administrator taken into consideration from add_employee function

-- add_course_offering(input_Course_id INT, input_Fees NUMERIC(36,2), input_Launch_date DATE, input_Registration_deadline DATE, 
  --                  input_Eid INT, input_Target_registration INT, input_SessionDateAndTime TIMESTAMP[], input_Rid INT[])
CALL add_course_offering(2, 55, '2021-01-02', '2021-05-02', 32, 5, array['2021-06-20 15:00:00', '2021-06-11 15:00:00']::TIMESTAMP[], array[1,5]);
CALL add_course_offering(3, 60, '2021-01-03', '2021-05-03', 33, 5, array['2021-06-21 15:00:00', '2021-06-12 15:00:00']::TIMESTAMP[], array[5,6]);
CALL add_course_offering(4, 65, '2021-01-04', '2021-05-04', 34, 5, array['2021-06-22 15:00:00', '2021-06-13 15:00:00']::TIMESTAMP[], array[9,23]);
CALL add_course_offering(5, 70, '2021-01-05', '2021-05-05', 35, 5, array['2021-06-23 15:00:00', '2021-06-14 15:00:00']::TIMESTAMP[], array[5,16]);
CALL add_course_offering(6, 75, '2021-01-06', '2021-05-06', 36, 5, array['2021-06-24 15:00:00', '2021-06-15 15:00:00']::TIMESTAMP[], array[8,19]);
CALL add_course_offering(7, 80, '2021-01-07', '2021-05-07', 37, 5, array['2021-06-25 15:00:00', '2021-06-17 15:00:00']::TIMESTAMP[], array[9,10]);
CALL add_course_offering(8, 85, '2021-01-08', '2021-05-08', 38, 5, array['2021-06-26 15:00:00', '2021-06-16 15:00:00']::TIMESTAMP[], array[13,9]);
CALL add_course_offering(9, 90, '2021-01-09', '2021-05-09', 39, 5, array['2021-06-27 15:00:00', '2021-06-18 15:00:00']::TIMESTAMP[], array[2,3]);
CALL add_course_offering(1, 50, '2021-01-01', '2021-05-01', 31, 5, array['2021-06-28 15:00:00', '2021-06-19 15:00:00']::TIMESTAMP[], array[4,5]);
<<<<<<< HEAD
CALL add_course_offering(10, 95, '2021-01-10', '2021-04-18', 32, 2, array['2021-06-29 15:00:00', '2021-06-20 15:00:00']::TIMESTAMP[], array[9,10]);
CALL add_course_offering(11, 100, '2021-01-11', '2021-04-19', 31, 1, array['2021-07-25 15:00:00', '2021-07-13 15:00:00']::TIMESTAMP[], array[3,1]);
CALL add_course_offering(12, 105, '2021-01-12', '2021-04-20', 32, 2, array['2021-07-26 15:00:00', '2021-07-15 15:00:00']::TIMESTAMP[], array[3,5]);
CALL add_course_offering(13, 110, '2021-01-13', '2021-04-21', 33, 3, array['2021-07-27 15:00:00', '2021-07-17 15:00:00']::TIMESTAMP[], array[2,3]);
CALL add_course_offering(14, 115, '2021-01-14', '2021-04-22', 34, 4, array['2021-07-28 15:00:00', '2021-07-19 15:00:00']::TIMESTAMP[], array[2,1]);
CALL add_course_offering(15, 120, '2021-01-15', '2021-04-23', 40, 5, array['2021-07-29 15:00:00', '2021-07-21 15:00:00']::TIMESTAMP[], array[6,1]);
=======
CALL add_course_offering(10, 95, '2021-01-10', '2021-05-10', 32, 2, array['2021-06-29 15:00:00', '2021-06-20 15:00:00']::TIMESTAMP[], array[9,10]);
CALL add_course_offering(11, 100, '2021-01-11', '2021-05-11', 31, 1, array['2021-07-25 15:00:00', '2021-07-13 15:00:00']::TIMESTAMP[], array[3,1]);
CALL add_course_offering(12, 105, '2021-01-12', '2021-05-12', 32, 2, array['2021-07-26 15:00:00', '2021-07-15 15:00:00']::TIMESTAMP[], array[3,5]);
CALL add_course_offering(13, 110, '2021-01-13', '2021-05-13', 33, 3, array['2021-07-27 15:00:00', '2021-07-17 15:00:00']::TIMESTAMP[], array[2,3]);
CALL add_course_offering(14, 115, '2021-01-14', '2021-05-14', 34, 4, array['2021-07-28 15:00:00', '2021-07-19 15:00:00']::TIMESTAMP[], array[2,1]);
CALL add_course_offering(15, 120, '2021-01-15', '2021-05-15', 40, 5, array['2021-07-29 15:00:00', '2021-07-21 15:00:00']::TIMESTAMP[], array[6,1]);
>>>>>>> c48e3649d3f2aaf3a74b2092b5718224ee2d3d42

-- register_session(input_cust_id INT, input_course_id INT, input_launch_date DATE, input_session_number INT, 'credit card') 
DELETE FROM Registers;
CALL register_session(1,1,'2021-01-01', 1,'credit card');           
CALL register_session(2,2,'2021-01-02', 1,'credit card');                                            
CALL register_session(3,3,'2021-01-03', 1,'credit card');                                            
CALL register_session(4,4,'2021-01-04', 1,'credit card');                                            
CALL register_session(5,5,'2021-01-05', 1,'credit card');           
CALL register_session(6,6,'2021-01-06', 1,'credit card');
CALL register_session(7,7,'2021-01-07', 1,'credit card');
CALL register_session(8,8,'2021-01-08', 2,'credit card');
CALL register_session(9,9,'2021-01-09', 2,'credit card');
CALL register_session(10,10,'2021-01-10', 2,'credit card');
CALL register_session(11,11,'2021-01-11', 2,'credit card'); 
CALL register_session(12,12,'2021-01-12', 2,'credit card');
CALL register_session(13,13,'2021-01-13', 2,'credit card');
CALL register_session(14,14,'2021-01-14', 2,'credit card');
CALL register_session(15,15,'2021-01-15', 2,'credit card');                          

-- register_session(input_cust_id INT, input_course_id INT, input_launch_date DATE, input_session_number INT, 'redemption') 
DELETE FROM Redeems;
CALL register_session(16,2,'2021-01-02',1,'redemption');
CALL register_session(17,3,'2021-01-03',1,'redemption');
CALL register_session(18,3,'2021-01-03',1,'redemption');
CALL register_session(19,4,'2021-01-04',1,'redemption');
CALL register_session(20,5,'2021-01-05',1,'redemption');
CALL register_session(21,6,'2021-01-06',1,'redemption');
CALL register_session(22,7,'2021-01-07',1,'redemption');
CALL register_session(23,8,'2021-01-08',1,'redemption');
CALL register_session(24,9,'2021-01-09',2,'redemption');
CALL register_session(25,10,'2021-01-10',2,'redemption');
CALL register_session(26,11,'2021-01-11',2,'redemption');
CALL register_session(27,12,'2021-01-12',2,'redemption');
CALL register_session(28,13,'2021-01-13',2,'redemption');
CALL register_session(29,14,'2021-01-14',2,'redemption');
CALL register_session(30,15,'2021-01-15',2,'redemption');

DELETE FROM Pay_slips;
SELECT * FROM pay_salary();

DELETE FROM Cancels;
--cancel_registration(input_cust_id INT, input_course_id INT, input_launch_date DATE)
--cancel from registers
CALL cancel_registration(1,1, '2021-01-01');
CALL cancel_registration(2,2, '2021-01-02');
CALL cancel_registration(3,3, '2021-01-03');
CALL cancel_registration(4,4, '2021-01-04');
CALL cancel_registration(5,5, '2021-01-05');
--cancel from redeems
CALL cancel_registration(16,2, '2021-01-02');
CALL cancel_registration(17,3, '2021-01-03');
CALL cancel_registration(18,3, '2021-01-03');
CALL cancel_registration(19,4, '2021-01-04');
CALL cancel_registration(20,5, '2021-01-05');