use AdventureWorks;

--left outer join--
select  count(*) as totalRows
from Sales.SalesOrderHeader
left join Sales.CurrencyRate
on (Sales.SalesOrderHeader.CurrencyRateID = Sales.CurrencyRate.CurrencyRateID)
left join Sales.Currency
on (Sales.CurrencyRate.ToCurrencyCode = Sales.Currency.CurrencyCode)
inner join Person.Address
on (Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID);

--inner join--
select  count(*) as totalRows
from Sales.SalesOrderHeader
inner join Sales.CurrencyRate
on (Sales.SalesOrderHeader.CurrencyRateID = Sales.CurrencyRate.CurrencyRateID)
inner join Sales.Currency
on (Sales.CurrencyRate.ToCurrencyCode = Sales.Currency.CurrencyCode)
inner join Person.Address
on (Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID);

