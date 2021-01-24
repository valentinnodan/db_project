create or replace function adoptCat2()
    returns trigger as
$adoptCat$
BEGIN
    delete from CatDonations 
    where exists(select 1
              from CatNecessities
              where CatDonations.necessityId = CatNecessities.necessityId and CatNecessities.catId = old.catId);

    delete from CatContributions 
    where exists(select 1
              from CatNecessities
              where CatContributions.necessityId = CatNecessities.necessityId and CatNecessities.catId = old.catId);

    delete from CatActivities 
    where exists(select 1
              from CatNecessities
              where CatActivities.necessityId = CatNecessities.necessityId and CatNecessities.catId = old.catId);

    delete from CatNecessities
    where catId = old.catId;

    
    return old;

END
$adoptCat$
    language 'plpgsql';

create trigger updateTablesOnCatAdoption
    before delete
    on Cats
    for each row
execute procedure adoptCat2();
