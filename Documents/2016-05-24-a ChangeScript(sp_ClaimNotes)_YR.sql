USE [Integra]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 IF EXISTS (SELECT ChangeScript From ChangeScript Where ScriptName = '2016-05-24-a ChangeScript(sp_ClaimNotes)_YR.sql')
BEGIN
	RAISERROR ('Script has already been run', 20, 1) WITH LOG
END
GO
/* Modification History :
----------------------------------------------------------
When?          Who?             What?
02/12/2015   YallaReddy      Fixes for QI-929 to display Note Created By & Date
----------------------------------------------------------
*/
ALTER PROCEDURE [dbo].[sp_ClaimNotes]
	@top int,
	@ClaimKey int,
	@IsProvider bit
AS  

    DECLARE @OrigClaim INT;
	DECLARE @CVersion TABLE(Claim INT PRIMARY KEY, ClaimVer varchar(40))
		
	-- Getting all Original Claims for Current Claim
	SELECT @OrigClaim=OrigClaim FROM dbo.[v_ClaimVersion] where claim=@ClaimKey
				
	-- Getting all & Claim Claim Versions for Original Claims
	INSERT INTO @CVersion		
	SELECT Claim, [ClaimVer] FROM [dbo].[v_ClaimVersion] WHERE OrigClaim=@OrigClaim;	
	
	--DECLARE @ClaimNotes TABLE(WAF_PKey INT PRIMARY KEY, Team VARCHAR(40), Table_Name VARCHAR(40), Table_Key INT, [Login] VARCHAR(50),
	--						  NoteStatus VARCHAR(40), FollowUp DATETIME, Message VARCHAR(MAX), AttachedFile VARCHAR(255), AttachedFileValue VARCHAR(255),
	--						  CreateDate DATETIME, IsVisibleForProviders BIT, CreatedBy	VARCHAR(60), Claim VARCHAR(40), ClaimVer VARCHAR(40)
	--						 )

   --INSERT INTO @ClaimNotes
	-- Selecting Notes for All associated Claim & Original Claims
	SELECT TOP (@top) Note.Note AS "WAF_PKey", 
				Team.Name AS "Team", 
				Note.Table_Name, Note.Table_Key,
				L1.OrderedName AS "Login", 
				Note.NoteStatus AS "NoteStatus", 
				Note.FollowUp AS "FollowUp", 
				Note.Notation AS "Message", 
				Note.AttachedFile AS "AttachedFile", 
				Note.AttachedFile AS "AttachedFileValue",
				Note.CreateDate, 
				Note.IsVisibleForProviders,
				L.OrderedName AS "CreatedBy", 
				B.Claim,
				B.ClaimVer
			FROM Note 
				LEFT OUTER JOIN Team ON Note.Team = Team.Team 
				LEFT OUTER JOIN [Login] L1 ON Note.[Login] = L1.[Login] 
				LEFT OUTER JOIN [Login] L ON Note.CreatedBy = L.[Login] 
				JOIN @CVersion B ON Note.Table_Key= B.claim
				WHERE Note.Table_Name = N'Claim' 
				AND (@IsProvider=0 OR  Note.IsVisibleForProviders=1)				 

  UNION ALL

	 -- Selecting Notes for All associated with Payments for Claim
	 SELECT TOP (@top) Note.Note AS "WAF_PKey", 
				Team.Name AS "Team", 
				Note.Table_Name, Note.Table_Key,
				L1.OrderedName AS "Login", 
				Note.NoteStatus AS "NoteStatus", 
				Note.FollowUp AS "FollowUp", 
				Note.Notation AS "Message", 
				Note.AttachedFile AS "AttachedFile", 
				Note.AttachedFile AS "AttachedFileValue",
				Note.CreateDate, 
				Note.IsVisibleForProviders,
				L.OrderedName AS "CreatedBy", 
				C.Claim,
				C.ClaimVer
			FROM Note 
			    JOIN Payment P ON Note.Table_Key = P.Payment AND Note.Table_Name = 'Payment'
				JOIN Claim C ON C.Claim = P.Claim AND C.Claim = @ClaimKey
				LEFT OUTER JOIN Team ON Note.Team = Team.Team 
				LEFT OUTER JOIN [Login] L1 ON Note.[Login] = L1.[Login] 
				LEFT OUTER JOIN [Login] L ON Note.CreatedBy = L.[Login]
				WHERE (@IsProvider=0 OR  Note.IsVisibleForProviders=1)
				
	-- DECLARE @sql nvarchar(max);
	-- SELECT @sql = N'
		-- DECLARE @OrigClaim int
		-- select @OrigClaim=OrigClaim from dbo.[v_ClaimVersion] where claim=@ClaimKey
		-- declare @CVersion TABLE(claim int PRIMARY KEY, claimver varchar(40))
		-- insert into @CVersion select claim,[claimver]  from [dbo].[v_ClaimVersion] where OrigClaim=@OrigClaim  '

	-- SELECT @sql = @sql+ N' SELECT  TOP ##top## Note.Note AS "WAF_PKey", 
					-- Team.Name AS "Team", Login.OrderedName AS "Login", 
					-- Note.NoteStatus AS "NoteStatus", 
					-- Note.FollowUp AS "FollowUp", 
					-- Note.Notation AS "Message", 
					-- Note.AttachedFile AS "AttachedFile", 
					-- Note.AttachedFile AS "AttachedFileValue",
					-- Note.CreateDate, L.OrderedName AS "CreatedBy", 
					-- B.Claim, B.ClaimVer
					-- FROM Note 
					-- LEFT OUTER JOIN Team ON Note.Team = Team.Team 
					-- LEFT OUTER JOIN Login ON Note.Login = Login.Login 
					-- LEFT OUTER JOIN Login L ON Note.CreatedBy = L.Login 
					-- join @CVersion B
					-- on Note.Table_Key=B.claim
					-- WHERE Note.Table_Name = N''Claim'' 
					-- ##IsVisibleForProviders##
					-- ORDER BY Note.CreateDate DESC';

	-- SELECT @sql = REPLACE(@sql, '##top##', @top);
	-- if @IsProvider=1
	-- SELECT @sql = REPLACE(@sql, '##IsVisibleForProviders##', ' AND IsVisibleForProviders=1');
	-- else
	-- SELECT @sql = REPLACE(@sql, '##IsVisibleForProviders##', '');
	-- EXEC sp_executesql @sql, N' @ClaimKey int',  @ClaimKey = @ClaimKey

GO
IF (@@ERROR = 0)
BEGIN
	INSERT INTO ChangeScript(ScriptName, ScriptDescription, CreatedBy)
    VALUES ('2016-05-24-a ChangeScript(sp_ClaimNotes)_YR.sql', 'Fixes for QI-1272 to display Transactions Notes in Claim page', 'YallaReddy')
END