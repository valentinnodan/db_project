-- Список всех котов приюта
select Cats.catId, Cats.name
from Cats
where Cats.shelterId = 1;

-- Для каждого кота сумма всех затрат на него
select Cats.catId, Cats.name, sum(CatNecessities.neededMoney) as moneyAmount
from Cats,
     CatNecessities
where Cats.catId = CatNecessities.catId
group by (Cats.catId, Cats.name);

-- Для каждого приюта вывести количество денег, когда-либо необходимых ему
select shelterId, sum(moneyAmount)
from (
      (select shelterId, sum(neededMoney) as moneyAmount
       from ShelterNecessities
       group by shelterId
      )
      union all
      (select shelterId, sum(CatNecessities.neededMoney) as moneyAmount
       from Cats, CatNecessities
       where Cats.catId = CatNecessities.catId
       group by shelterId
      )
    ) as CatsSheltersAmounts
group by shelterId;

-- Для волонтера найти приют, которому он больше всего помогает
select shelterId, count(*) as HelpCount from
    (select personId, shelterId
     from Volunteers natural join ShelterContributions natural join ShelterNecessities
    ) as allHelps
where personId = 1
group by personId, shelterId
order by HelpCount desc limit 1;

-- Для спонсора найти приют, которому он активнее всего помогает
select shelterId, count(*) as HelpCount
from (select personId, shelterId
      from Sponsors natural join ShelterDonations natural join ShelterNecessities
     ) as allHelps
where personId = 3
group by personId, shelterId
order by HelpCount desc limit 1;

-- Найти 5 самых активных волонтеров
select personId, sum(CountSponsor) as totalContribution
from (
      (select personId, count(*) as countSponsor
       from Volunteers natural join CatContributions
       group by personId
      )
      union all
        (select personId, count(*) as countSponsor
         from Volunteers natural join ShelterContributions
         group by personId
        )
    ) as SponsorsMerged
group by personId order by totalContribution desc limit 5;

-- Найти 5 самых активных спонсоров
select personId, sum(CountSponsor) as totalContribution
from (
      (select personId, count(*) as countSponsor
       from Sponsors natural join CatDonations
       group by personId
      )
      union all
      (select personId, count(*) as countSponsor
       from Sponsors natural join ShelterDonations
       group by personId)
    ) as SponsorsMerged
group by personId order by totalContribution desc limit 5;

-- Для каждого волонтера получить количество активностей, в которых он помог
select Persons.personId, Persons.name, Persons.surname, sum(activitiesCount)
from (select personId, count(*) as activitiesCount
      from ShelterContributions
      group by (personId)
      union all
      select personId, count(*) as activitiesCount
      from CatContributions
      group by (personId)
     ) as CountsMerged
    natural join Persons
group by (Persons.personId, Persons.name, Persons.surname);

-- Для спонсора получить количество пожертвованных денег
select Persons.personId, Persons.name, Persons.surname, sum(donationCount)
from (select personId, sum(money) as donationCount
      from CatDonations
      group by (personId)
      union all
      select personId, sum(money) as donationCount
      from ShelterDonations
      group by (personId)
     ) as CountsMerged
         natural join Persons
group by (Persons.personId, Persons.name, Persons.surname);

-- Получить список доступных для участия ShelterActivities
select necessityId, activityName
from ShelterActivities
where (necessityId, activityName) not in
    (select necessityId, activityName
     from ShelterContributions
    );

-- Получить список доступных для пожертвования нужд для приюта
select necessityId
from ShelterNecessities
where (necessityId, neededMoney) not in
      (select necessityId, sum(ShelterDonations.money)
       from ShelterDonations
       group by necessityId
      ) and neededMoney > 0;
