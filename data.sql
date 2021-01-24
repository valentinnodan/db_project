insert into Persons (personId, name, surname) values
(1, 'Valentina', 'Danilova'),
(2, 'Polina', 'Burtseva'),
(3, 'Ololo', 'Ololoev'),
(4, 'Nikolay', 'Baskov'),
(5, 'Irina', 'Rodionova'),
(6, 'Pavel', 'Mavrin'),
(7, 'Nikolay', 'Morozov');
insert into Sponsors (personId, moneyLimit) values
(1, 500),
(3, 2000),
(4, 1000000),
(7, 1000);
insert into Volunteers (personId, activitiesLimit) values
(1, 4),
(2, 2),
(5, 100);
insert into Shelters (shelterId, name) values
(1, 'Pets'),
(2, 'Mur');
insert into Cats (catId, shelterId, name, hairColor) values
(1, 1, 'Murka', 'red'),
(2, 2, 'Barsik', 'black'),
(3, 1, 'Matilda', null),
(4, 2, 'Boris', 'black white')
;
insert into CatNecessities (necessityId, catId, name, neededMoney, description) values
(1, 4, 'special feed for Boris', 700, null),
(2, 3, 'eye drops for Matilda', 500, 'Matilda is waiting for your help!'),
(3, 1, 'neutering Murka', 2000, null),
(4, 2, 'get passport', 0, null)
;
insert into ShelterNecessities (necessityId, shelterId, name, neededMoney, description) values
(1, 1, 'clean territory', 0, null),
(2, 2, 'rent', 1000, 'need help with paying rent'),
(3, 1, 'new dishes for cats', 5000, null),
(4, 2, 'buy new trays', 2000, null)
;
insert into CatActivities (necessityId, activityName, description) values
(2, 'buy and deliver eye drops', null),
(2, 'drip drops to Matilda eyes', 'Be careful, Matilda does not like drops'),
(3, 'deliver to veterinary hospital', null),
(3, 'take care after operation', 'Murka will need to drink more'),
(4, 'deliver Barsik to hospital', null)
;
insert into ShelterActivities (necessityId, activityName, description) values
(1, 'wash cats dishes', null),
(1, 'empty trays', null),
(1, 'wash floors', 'without chemicals, cats licking floors'),
(3, 'buy and deliver dishes', null),
(2, 'go to bank and pay', null)
;
insert into ShelterContributions (personId, necessityId, activityName, contributionDate) values
(1, 1, 'empty trays', '2021-01-01'),
(2, 3, 'buy and deliver dishes', '2021-01-15'),
(1, 1, 'wash floors', '2021-01-01'),
(1, 2, 'go to bank and pay', '2021-01-15')
;
insert into CatContributions (personId, necessityId, activityName, contributionDate) values
(5, 3, 'deliver to veterinary hospital', '2021-01-9'),
(5, 3, 'take care after operation', '2021-01-10'),
(1, 2, 'buy and deliver eye drops', '2020-01-11'),
(2, 4, 'deliver Barsik to hospital', '2021-01-12')
;
insert into ShelterDonations (personId, necessityId, donationDate, money) values
(4, 3, '2021-01-14', 5000),
(3, 2, '2021-01-20', 800),
(7, 2, '2021-01-21', 200)
;
insert into CatDonations (personId, necessityId, donationDate, money) values
(4, 3, '2021-02-05', 2000),
(3, 1, '2021-01-17', 700),
(3, 2, '2021-01-31', 500)
;