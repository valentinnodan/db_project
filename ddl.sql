create table Persons (
    personId int not null,
    name varchar(50) not null,
    surname varchar(50) not null,
    primary key (personId)
);

create table Sponsors (
    personId int not null,
    moneyLimit int not null,
    primary key (personId),
    foreign key (personId) references Persons (personId)
);

create table Volunteers (
    personId int not null,
    activitiesLimit int not null,
    primary key (personId),
    foreign key (personId) references Persons (personId)
);

create table Shelters (
    shelterId int not null,
    name varchar(50) not null,
    primary key (shelterId)
);

create table Cats (
    catId int not null,
    shelterId int not null,
    name varchar(50) not null,
    hairColor varchar(20),
    primary key (catId),
    foreign key (shelterId) references Shelters (shelterId)
);

create table ShelterNecessities (
    necessityId int not null,
    shelterId int not null,
    name varchar(100) not null,
    neededMoney int not null,
    description text,
    primary key (necessityId),
    foreign key (shelterId) references Shelters (shelterId)
);

create table CatNecessities (
    necessityId int not null,
    catId int not null,
    name varchar(100) not null,
    neededMoney int not null,
    description text,
    primary key (necessityId),
    foreign key (catId) references Cats (catId)
);

create table CatActivities (
    necessityId int not null,
    activityName varchar(100) not null,
    description text,
    primary key (necessityId, activityName),
    foreign key (necessityId) references CatNecessities (necessityId)
);

create table ShelterActivities (
    necessityId int not null,
    activityName varchar(100) not null,
    description text,
    primary key (necessityId, activityName),
    foreign key (necessityId) references ShelterNecessities (necessityId)
);

create table CatContributions (
    personId int not null,
    necessityId int not null,
    activityName varchar(100) not null,
    contributionDate date not null,
    primary key (personId, necessityId, activityName),
    foreign key (personId) references Volunteers (personId),
    foreign key (necessityId, activityName) references CatActivities (necessityId, activityName)
);
create table ShelterContributions (
    personId int not null,
    necessityId int not null,
    activityName varchar(100) not null,
    contributionDate date not null,
    primary key (personId, necessityId, activityName),
    foreign key (personId) references Volunteers (personId),
    foreign key (necessityId, activityName) references ShelterActivities (necessityId, activityName)
);
create table CatDonations (
    personId int not null,
    necessityId int not null,
    donationDate date not null,
    money int not null,
    primary key (personId, necessityId),
    foreign key (personId) references Sponsors (personId),
    foreign key (necessityId) references CatNecessities (necessityId)
);
create table ShelterDonations (
    personId int not null,
    necessityId int not null,
    donationDate date not null,
    money int not null,
    primary key (personId, necessityId),
    foreign key (personId) references Sponsors (personId),
    foreign key (necessityId) references ShelterNecessities (necessityId)
);

create index activityByPerson on ShelterContributions using btree (personId, activityName);
create index shelterContributionPersonWithActitity on ShelterContributions using btree (activityName, personId);

create index catActivityByPerson on CatDonations using btree (personId, necessityId);
create index catPersonsWithActivity on CatDonations using btree (necessityId, personId);

create index catNecessityByActivity on CatActivities using btree (activityName, necessityId);
create index catActivityByNecessity on CatActivities using btree (necessityId, activityName);

create index catPersonContributionByActivity on CatContributions using btree (personId, activityName);
create index personByActivityActContibution on CatContributions using btree (activityName, personId);

create index necessityByPersonShelterDonations on ShelterDonations using btree (personId, necessityId);
create index personByNecessityShelterDonations on ShelterDonations using btree (necessityId, personId);


create index necessityByActivity on ShelterActivities using btree (activityName, necessityId);
create index activityByNecessity on ShelterActivities using btree (necessityId, activityName);

create index moneyById on Sponsors using btree (personId, moneyLimit);
create index activitiesLimitById on Volunteers using btree (personId, activitiesLimit);

create index nameByShelterId on Shelters using btree (shelterId, name);

create index shelterByCat on Cats using btree (catId, shelterId);
create index catsByShelter on Cats using btree (shelterId, catId);

