------------------------------------------------------------------------------------------------
-- xml parsing examples because just not used enough to know
------------------------------------------------------------------------------------------------
SELECT
  id
  , xmlField
  , xmlField.query('(/CUSTOMER/MSG_SECTION)[1]')
  , xmlField.query('(/CUSTOMER/MSG_SECTION/MSG[1])[1]')
FROM dbo.table1


UPDATE dbo.table1
  SET xmlField.modify('delete(/CUSTOMER/MSG_SECTION)[1]')
WHERE id = 1

UPDATE dbo.table1
  SET xmlField.modify('insert(<MSG_SECTION><MSG /></MSG_SECTION)after(/CUSTOMER/TOTALS_SECTION)[1]')
WHERE id = 1

UPDATE dbo.table1
  SET xmlField.modify('insert(<MSG>{sql:variable("@test2")}</MSG>)after(/CUSTOMER/MSG_SECTION/MSG)[1]')
WHERE id = 1

UPDATE dbo.table1
  SET xmlField.modify('replace value of (/CUSTOMER/MSG_SECTION/@MSG[1])[1] with {sql:variable("@Msg12")}')
WHERE id = 1


SELECT
  id
  , name
  , xmlField.value('(/PERSON/ADDRESS/CITY/@description)[1]', 'varchar(100)') as addressCity
FROM dbo.table1
