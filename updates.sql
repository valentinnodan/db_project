-- Read uncommitted
create or replace function donateToShelterNecessity(myPersonId int, myNecessityId int, myMoney int)
    returns void as
$$
BEGIN
    insert into ShelterDonations (personId, necessityId, donationDate, money) values
    (myPersonId, myNecessityId, current_date, myMoney);
END
$$
    language 'plpgsql';

-- Read uncommitted
create or replace function donateToCatNecessity(myPersonId int, myNecessityId int, myMoney int)
    returns void as
$$
BEGIN
    insert into CatDonations (personId, necessityId, donationDate, money) values
    (myPersonId, myNecessityId, current_date, myMoney);
END
$$
    language 'plpgsql';

-- Read uncommitted
create or replace function contributeToShelter(myPersonId int, myNecessityId int, myActivityName varchar(100))
    returns void as
$$
BEGIN
    insert into ShelterContributions (personId, necessityId, activityName, contributionDate) values
    (myPersonId, myNecessityId, myActivityName, current_date);
END
$$
    language 'plpgsql';

-- Read uncommitted
create or replace function contributeToCat(myPersonId int, myNecessityId int, myActivityName varchar(100))
    returns void as
$$
BEGIN
    insert into CatContributions (personId, necessityId, activityName, contributionDate) values
    (myPersonId, myNecessityId, myActivityName, current_date);
END
$$
    language 'plpgsql';

-- Read committed
-- Взять кота из приюта
create or replace function adoptCat()
    returns trigger as
$adoptCat$
BEGIN
    delete from CatDonations
    using CatNecessities
    where CatDonations.necessityId = CatNecessities.necessityId and
          CatNecessities.catId = deleted.catId;
    delete from CatContributions
    using CatNecessities
    where CatContributions.necessityId = CatNecessities.necessityId and
          CatNecessities.catId = deleted.catId;
    delete from CatActivities
    using CatNecessities
    where CatActivities.necessityId = CatNecessities.necessityId and
          CatNecessities.catId = deleted.catId;
    delete from CatNecessities
    where catId = deleted.catId;
    delete from Cats
    where catId = deleted.catId;
END
$adoptCat$
    language 'plpgsql';

create trigger updateTablesOnCatAdoption
    before delete
    on Cats
    for each row
execute procedure adoptCat();

-- Read uncommitted
create or replace function addShelterNecessity(myNecessityId int, myShelterId int, myName varchar(100), myNeededMoney int, myDescription text)
    returns void as
$$
BEGIN
    insert into ShelterNecessities (necessityId, shelterId, name, neededMoney, description) values
    (myNecessityId, myShelterId, myName, myNeededMoney, myDescription);
END
$$
    language 'plpgsql';

-- Read uncommitted
create or replace function addCatNecessity(myNecessityId int, myCatId int, myName varchar(100), myNeededMoney int, myDescription text)
    returns void as
$$
BEGIN
    insert into CatNecessities (necessityId, catId, name, neededMoney, description) values
    (myNecessityId, myCatId, myName, myNeededMoney, myDescription);
END
$$
    language 'plpgsql';


-- Read uncommitted
create or replace function addCatActivity(myNecessityId int, myName varchar(100), myDescription text)
    returns void as
$$
BEGIN
    insert into CatActivities (necessityId, activityName, description) values
    (myNecessityId, myName, myDescription);
END
$$
    language 'plpgsql';

-- Read uncommitted
create or replace function addShelterActivity(myNecessityId int, myName varchar(100), myDescription text)
    returns void as
$$
BEGIN
    insert into ShelterActivities (necessityId, activityName, description) values
    (myNecessityId, myName, myDescription);
END
$$
    language 'plpgsql';

-- Read committed
create or replace function addNewDonation()
    returns trigger as
$addNewDonation$
declare
    myMoneyLimit int :=
        (select moneyLimit
         from Sponsors
         where personId = new.personId
        );
    moneySpentOnShelterCurMonth int :=
        (select sum(money)
         from ShelterDonations
         where ShelterDonations.personId = new.personId and
                extract( month from ShelterDonations.donationDate) = extract(month from new.donationDate)
        );
    moneySpentOnCatsCurMonth int :=
        (select sum(money)
         from CatDonations
         where CatDonations.personId = new.personId and
                extract( month from CatDonations.donationDate) = extract( month from new.donationDate)
        );
begin
    if new.money + coalesce(moneySpentOnShelterCurMonth,0) + coalesce(moneySpentOnCatsCurMonth,0) <= myMoneyLimit then
        return new;
    end if;
    return old;
end;
$addNewDonation$
    language plpgsql;

-- Триггер на месячный лимит расходов у спонсора на каждое пожертвование для кота
create trigger cantOverflowBudgetCat
    before insert or update
    on CatDonations
    for each row
execute procedure addNewDonation();

-- Триггер на месячный лимит расходов у спонсора на каждое пожертвование для приюта
create trigger cantOverflowBudgetShelter
    before insert or update
    on ShelterDonations
    for each row
execute procedure addNewDonation();

select * from donateToCatNecessity(4, 2, 590000000);

-- Read committed
create or replace function noOverPayFunctionCat()
    returns trigger as
$noOverPayFunction$
declare
    moneySpentOnNecessity int :=
        (select sum(money)
         from CatDonations
         where CatDonations.necessityId = new.necessityId
        );
    moneyNeeded int :=
        (select neededMoney
         from CatNecessities
         where CatNecessities.necessityId = new.necessityId
        );
begin
    if new.money + coalesce(moneySpentOnNecessity,0) <= moneyNeeded then
        return new;
    end if;
    return old;
end;
$noOverPayFunction$ language plpgsql;

-- Read committed
create or replace function noOverPayFunctionShelter()
    returns trigger as
$noOverPayFunction$
declare
    moneySpentOnNecessity int :=
        (select sum(money)
         from ShelterDonations
         where ShelterDonations.necessityId = new.necessityId
        );
    moneyNeeded int :=
        (select neededMoney
         from ShelterNecessities
         where ShelterNecessities.necessityId = new.necessityId
        );
begin
    if new.money + coalesce(moneySpentOnNecessity,0) <= moneyNeeded then
        return new;
    end if;
    return old;
end;
$noOverPayFunction$ language plpgsql;

-- Триггер, не позволяющий спонсору переплачивать за нужды кота
create trigger noOverPayCat
    before insert or update
    on CatDonations
    for each row
execute procedure noOverPayFunctionCat();

-- Триггер на месячный лимит расходов у спонсора на каждое пожертвование для приюта
create trigger noOverPayShelter
    before insert or update
    on ShelterDonations
    for each row
execute procedure noOverPayFunctionShelter();

-- Read committed
create or replace function cantOverflowScheduleFunction()
    returns trigger as
$cantOverflowScheduleFunction$
declare
    myActivityLimit int := (select activitiesLimit
                            from Volunteers
                            where personId = new.personId
                           );
    activityPointsOnShelterCurMonth int :=
        (select count(*)
         from ShelterContributions
         where ShelterContributions.personId = new.personId and
                extract( month from ShelterContributions.contributionDate) = extract(month from current_date)
        );
    activityPointsOnCatsCurMonth int :=
        (select count(*)
         from CatContributions
         where CatContributions.personId = new.personId and
               extract( month from CatContributions.contributionDate) = extract( month from current_date)
        );
begin
    if 1 + coalesce(activityPointsOnCatsCurMonth,0) + coalesce(activityPointsOnShelterCurMonth,0) <= myActivityLimit then
        return new;
    end if;
    return old;
end;
$cantOverflowScheduleFunction$ language plpgsql;

-- Триггер на месячный лимит участий в активностях на каждое участие для кота
create trigger cantOverflowScheduleCat
    before insert
    on CatContributions
    for each row
execute procedure cantOverflowScheduleFunction();

-- Триггер на месячный лимит участий в активностях на каждое участие для кота
create trigger cantOverflowScheduleShelter
    before insert
    on ShelterContributions
    for each row
execute procedure cantOverflowScheduleFunction();

select * from contributeToCat(1, 2, 'buy and deliver eye drops')

