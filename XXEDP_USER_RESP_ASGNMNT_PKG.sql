create or replace package XXEDP_USER_RESP_ASGNMNT_PKG 
as 
  function BeforeReportTrigger return boolean;
END XXEDP_USER_RESP_ASGNMNT_PKG;
/

create or replace package body XXEDP_USER_RESP_ASGNMNT_PKG 
as
    FUNCTION BeforeReportTrigger return boolean 
    is
    CURSOR C_HEADER_ANONYMOUS IS
		SELECT  FND_GLOBAL.CONC_REQUEST_ID REQUEST_ID,
				SYSDATE REPORT_RUN_DATE,
				'Vision Corporation' GRE_NAME,
				SYS_CONTEXT('USERENV', 'DB_NAME') INSTANCE_NAME, 
				'Anonymous' ORGANIZATION_D,
				NULL ORG_TYPE, 
				'Anonymous' TAB_NAME 
		 FROM   dual
         ;
		 
    HEADER_ANONYMOUS_REC C_HEADER_ANONYMOUS%ROWTYPE;
  
    CURSOR C_DETAIL_ANONYMOUS IS
        SELECT FND_GLOBAL.CONC_REQUEST_ID REQUEST_ID,
		       'Anonymous' ORG_NAME,
			   fu.USER_ID,
			   fu.USER_NAME,
			   NULL FULL_NAME,
			   NULL EMPLOYEE_NUMBER,
		       fu.start_date FROM_EFFECTIVE_DATE_U,
			   fu.end_date TO_EFFECTIVE_DATE_U,
			   fu.CREATED_BY,
			   (select user_name
			   from fnd_user
			   where user_id = fu.CREATED_BY) CREATED_BY_NAME,
			   fu.CREATION_DATE, 
			   fu.LAST_UPDATED_BY, 
			   (select user_name
			   from fnd_user
			   where user_id = fu.LAST_UPDATED_BY) LAST_UPDATED_BY_NAME, 
			   fu.last_update_date LAST_UPDATED_DATE, 
			   frt.RESPONSIBILITY_NAME,
			   app.APPLICATION_NAME, 
			   sg.security_group_name SECURITY_GROUP, 
			   gd.start_date FROM_EFFECTIVE_DATE_R, 
			   gd.end_date TO_EFFECTIVE_DATE_R, 
			   gd.created_by ASSIGNED_BY, 
			   (select user_name
			   from fnd_user
			   where user_id = gd.created_by) ASSIGNED_BY_NAME, 
			   gd.creation_date ASSIGNED_DATE, 
			   gd.last_updated_by ASSIGNMENT_UPDATED_BY, 
			   (select user_name
			   from fnd_user
			   where user_id = gd.last_updated_by) ASSIGNMENT_UPDATED_BY_NAME,
			   gd.last_update_date ASSIGNMENT_UPDATED_DATE      

		from   fnd_user fu,
			   fnd_user_resp_groups_direct gd,
			   fnd_security_groups_tl sg,
			   fnd_responsibility_tl frt,
			   fnd_application_tl app
		where (fu.employee_id IS NULL and fu.supplier_id IS NULL and fu.customer_id IS NULL)
		AND fu.user_id = gd.user_id
		AND gd.security_group_id = sg.security_group_id
		AND gd.responsibility_id = frt.responsibility_id 
		AND frt.LANGUAGE = 'US'
        AND frt.application_id = app.application_id		
		AND app.LANGUAGE = 'US'
		AND (TRUNC(fu.creation_date) between TO_DATE('01-JAN-2020') and TO_DATE('31-DEC-2020') OR
			 TRUNC(fu.last_update_date) between TO_DATE('01-JAN-2020') and TO_DATE('31-DEC-2020') OR
			 TRUNC(fu.start_date) between TO_DATE('01-JAN-2020') and TO_DATE('31-DEC-2020') OR
			 TRUNC(NVL(fu.end_date,TO_DATE('31-DEC-2020'))) between TO_DATE('01-JAN-2020') and TO_DATE('31-DEC-2020'))
        ;
	DETAIL_ANONYMOUS_REC C_DETAIL_ANONYMOUS%ROWTYPE;
	
	/* CURSOR C_HEADER_EMPLOYEE IS
		SELECT asigned_le.name GRE_Name,
			   aou.name ORG_NAME,
               aou.type ORG_TYPE,
               COUNT(*) CNT

		FROM   hr_all_organization_units aou,
              (select sckff.SOFT_CODING_KEYFLEX_ID, aou.name
               from HR_SOFT_CODING_KEYFLEX sckff, hr_all_organization_units aou
               where sckff.segment1 = to_char(organization_id)) asigned_le,
		       fnd_user fu,
			   fnd_user_resp_groups_direct gd,
			   fnd_security_groups_tl sg,
			   per_people_f per,
			   per_all_assignments_f paa,
			   fnd_responsibility_tl frt,
			   fnd_application_tl app
		WHERE aou.organization_id = paa.organization_id
        and paa.SOFT_CODING_KEYFLEX_ID = asigned_le.SOFT_CODING_KEYFLEX_ID
        and asigned_le.name = 'Vision Corporation' --use as a Parameter
		AND fu.user_id = gd.user_id
		AND gd.security_group_id = sg.security_group_id
		AND gd.responsibility_id = frt.responsibility_id 
		AND per.person_id = fu.employee_id
		AND paa.person_id = per.person_id
		AND fu.employee_id = per.person_id(+)
		AND frt.LANGUAGE = 'US'
        AND frt.application_id = app.application_id		
		AND app.LANGUAGE = 'US'
		and sysdate between paa.effective_start_date and nvl(paa.effective_end_date,sysdate+1)
        and sysdate between per.effective_start_date and nvl(per.effective_end_date,sysdate+1)
        GROUP BY aou.name, aou.type, asigned_le.name
        ;
		
	HEADER_EMPLOYEE_REC C_HEADER_EMPLOYEE%ROWTYPE; */
	

	
    CURSOR C_DETAIL_EMPLOYEE IS
        SELECT FND_GLOBAL.CONC_REQUEST_ID REQUEST_ID,
		       aou.name ORG_NAME,
			   aou.type ORG_TYPE,
			   fu.USER_ID,
			   fu.USER_NAME,
			   per.FULL_NAME,
			   per.EMPLOYEE_NUMBER,
		       fu.start_date FROM_EFFECTIVE_DATE_U,
			   fu.end_date TO_EFFECTIVE_DATE_U,
			   fu.CREATED_BY,
			   (select user_name
			   from fnd_user
			   where user_id = fu.CREATED_BY) CREATED_BY_NAME,
			   fu.CREATION_DATE, 
			   fu.LAST_UPDATED_BY, 
			   (select user_name
			   from fnd_user
			   where user_id = fu.LAST_UPDATED_BY) LAST_UPDATED_BY_NAME, 
			   fu.last_update_date LAST_UPDATED_DATE, 
			   frt.RESPONSIBILITY_NAME,
			   app.APPLICATION_NAME, 
			   sg.security_group_name SECURITY_GROUP, 
			   gd.start_date FROM_EFFECTIVE_DATE_R, 
			   gd.end_date TO_EFFECTIVE_DATE_R, 
			   gd.created_by ASSIGNED_BY, 
			   (select user_name
			   from fnd_user
			   where user_id = gd.created_by) ASSIGNED_BY_NAME, 
			   gd.creation_date ASSIGNED_DATE, 
			   gd.last_updated_by ASSIGNMENT_UPDATED_BY, 
			   (select user_name
			   from fnd_user
			   where user_id = gd.last_updated_by) ASSIGNMENT_UPDATED_BY_NAME,
			   gd.last_update_date ASSIGNMENT_UPDATED_DATE      

		FROM   hr_all_organization_units aou,
		      (select sckff.SOFT_CODING_KEYFLEX_ID, aou.name
               from HR_SOFT_CODING_KEYFLEX sckff, hr_all_organization_units aou
               where sckff.segment1 = to_char(organization_id)) asigned_le,
		       fnd_user fu,
			   fnd_user_resp_groups_direct gd,
			   fnd_security_groups_tl sg,
			   per_people_f per,
			   per_all_assignments_f paa,
			   fnd_responsibility_tl frt,
			   fnd_application_tl app
		WHERE aou.organization_id = paa.organization_id
		and paa.SOFT_CODING_KEYFLEX_ID = asigned_le.SOFT_CODING_KEYFLEX_ID
        and asigned_le.name = 'Vision Corporation' --use as a Parameter
		AND fu.user_id = gd.user_id
		AND gd.security_group_id = sg.security_group_id
		AND gd.responsibility_id = frt.responsibility_id 
		AND per.person_id = fu.employee_id
		AND paa.person_id = per.person_id
		AND fu.employee_id = per.person_id(+)
		AND frt.LANGUAGE = 'US'
        AND frt.application_id = app.application_id		
		AND app.LANGUAGE = 'US'
		and sysdate between paa.effective_start_date and nvl(paa.effective_end_date,sysdate+1)
        and sysdate between per.effective_start_date and nvl(per.effective_end_date,sysdate+1)
        ;
		
	DETAIL_EMPLOYEE_REC C_DETAIL_EMPLOYEE%ROWTYPE;
	
	TYPE HEADER_EMPLOYEE_TAB_TYPE IS TABLE OF C_HEADER_ANONYMOUS%ROWTYPE INDEX BY BINARY_INTEGER;
	HEADER_EMPLOYEE_TAB HEADER_EMPLOYEE_TAB_TYPE;
	idx NUMBER(2) := 0;
	FUNCTION CHECK_DUPLICATE(P_ORG_NAME VARCHAR2) RETURN BOOLEAN
	IS
	BEGIN
		IF HEADER_EMPLOYEE_TAB.COUNT = 0 THEN
		  RETURN FALSE;
		ELSE
		  FOR i IN 1..HEADER_EMPLOYEE_TAB.COUNT LOOP
			IF HEADER_EMPLOYEE_TAB(i).ORGANIZATION_D = P_ORG_NAME THEN
			  RETURN TRUE;
			END IF;
		  END LOOP;
		END IF;
		RETURN FALSE;
		DBMS_OUTPUT.PUT_LINE('Organization Name: '||HEADER_EMPLOYEE_TAB.ORGANIZATION_D);
	END;
	
    BEGIN
		OPEN C_HEADER_ANONYMOUS;
		LOOP
			FETCH C_HEADER_ANONYMOUS INTO HEADER_ANONYMOUS_REC;
			EXIT WHEN C_HEADER_ANONYMOUS%NOTFOUND;
			INSERT INTO XXUSER_RESPONSIBILITY_HEADER(REQUEST_ID, REPORT_RUN_DATE, GRE_NAME, INSTANCE_NAME, ORGANIZATION_D, ORGANIZATION_TYPE, TAB_NAME)
			VALUES(HEADER_ANONYMOUS_REC.REQUEST_ID, 
			       HEADER_ANONYMOUS_REC.REPORT_RUN_DATE, 
				   HEADER_ANONYMOUS_REC.GRE_NAME, 
				   HEADER_ANONYMOUS_REC.INSTANCE_NAME, 
				   HEADER_ANONYMOUS_REC.ORGANIZATION_D, 
				   HEADER_ANONYMOUS_REC.ORG_TYPE, 
				   HEADER_ANONYMOUS_REC.TAB_NAME);
		END LOOP;
		CLOSE C_HEADER_ANONYMOUS;
		
		/*OPEN C_HEADER_EMPLOYEE;
		LOOP
			FETCH C_HEADER_EMPLOYEE INTO HEADER_EMPLOYEE_REC;
			EXIT WHEN C_HEADER_EMPLOYEE%NOTFOUND;
			DECLARE
			  v_org_name VARCHAR2(240);
			  v_org_type_meaning VARCHAR2(80);
			  v_tab_name VARCHAR2(31);
			BEGIN
			  v_org_name := HEADER_EMPLOYEE_REC.ORG_NAME;
			  if HEADER_EMPLOYEE_REC.ORG_TYPE is not null then
			    select meaning 
			    INTO v_org_type_meaning
                from fnd_lookup_values
                where lookup_type = 'ORG_TYPE'
                and lookup_code = HEADER_EMPLOYEE_REC.ORG_TYPE;
			  end if;
			  v_tab_name := substr(HEADER_EMPLOYEE_REC.ORG_NAME,1,31);
			
			  INSERT INTO XXUSER_RESPONSIBILITY_HEADER(REQUEST_ID, REPORT_RUN_DATE, GRE_NAME, INSTANCE_NAME, ORGANIZATION_D, ORGANIZATION_TYPE, TAB_NAME)
			                                    VALUES(FND_GLOBAL.CONC_REQUEST_ID, 
			                                           SYSDATE, 
				                                       HEADER_EMPLOYEE_REC.GRE_NAME, 
				                                       SYS_CONTEXT('USERENV', 'DB_NAME'), 
				                                       v_org_name, 
				                                       v_org_type_meaning, 
				                                       v_tab_name);
			END;
		END LOOP;
		CLOSE C_HEADER_EMPLOYEE; */
		
     /* INSERT INTO XXUSER_RESPONSIBILITY_HEADER(REQUEST_ID, REPORT_RUN_DATE, GRE_NAME, INSTANCE_NAME, ORGANIZATION_D, ORGANIZATION_TYPE, TAB_NAME)
	                                 SELECT DISTINCT
											FND_GLOBAL.CONC_REQUEST_ID,
											SYSDATE REPORT_RUN_DATE,
  									        GRE_NAME, 
											SYS_CONTEXT('USERENV', 'DB_NAME') INSTANCE_NAME, 
											ORG_NAME ORGANIZATION_D, 
											ORG_TYPE ORGANIZATION_TYPE, 
											TAB_NAME
                                     FROM (SELECT asigned_le.name GRE_Name,
                                                      aou.name ORG_Name,
                                                      (select meaning 
                                                       from fnd_lookup_values
                                                       where lookup_type = 'ORG_TYPE'
                                                       and lookup_code = aou.type) ORG_Type,
                                                       substr(aou.name,1,31) Tab_Name,
                                                       fu.user_name,
                                                       pap.employee_number, pap.last_name, pap.first_name, paa.person_id, pap.person_type_id
                                               from hr_all_organization_units aou,
                                                       (select sckff.SOFT_CODING_KEYFLEX_ID, aou.name
                                                        from HR_SOFT_CODING_KEYFLEX sckff, hr_all_organization_units aou
                                                        where sckff.segment1 = to_char(organization_id)) asigned_le,
                                                        per_all_assignments_f paa,  per_all_people_f pap, fnd_user fu
                                               where aou.organization_id = paa.organization_id
                                               and paa.person_id = pap.person_id
                                               and paa.SOFT_CODING_KEYFLEX_ID = asigned_le.SOFT_CODING_KEYFLEX_ID
                                               and asigned_le.name = 'Vision Corporation' --use as a Parameter
                                               and pap.person_id = fu.employee_id
                                               and sysdate between paa.effective_start_date and nvl(paa.effective_end_date,sysdate+1)
                                               and sysdate between pap.effective_start_date and nvl(pap.effective_end_date,sysdate+1)) 
                                     ; */
		OPEN C_DETAIL_ANONYMOUS;
		LOOP
		  FETCH C_DETAIL_ANONYMOUS INTO DETAIL_ANONYMOUS_REC;
		  EXIT WHEN C_DETAIL_ANONYMOUS%NOTFOUND;
          INSERT INTO XXUSER_RESPONSIBILITY_DETAIL(REQUEST_ID, ORGANIZATION, USER_ID, USER_NAME, FULL_NAME, EMPLOYEE_NUMBER, FROM_EFFECTIVE_DATE_U, TO_EFFECTIVE_DATE_U,
	                                         CREATED_BY, CREATED_BY_NAME, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATED_BY_NAME, LAST_UPDATED_DATE, 
	                                         RESPONSIBILITY_NAME, APPLICATION_NAME, SECURITY_GROUP, FROM_EFFECTIVE_DATE_R, TO_EFFECTIVE_DATE_R, ASSIGNED_BY, 
									         ASSIGNED_BY_NAME, ASSIGNED_DATE, ASSIGNMENT_UPDATED_BY, ASSIGNMENT_UPDATED_BY_NAME, ASSIGNMENT_UPDATED_DATE)
                VALUES(DETAIL_ANONYMOUS_REC.REQUEST_ID, 
                       DETAIL_ANONYMOUS_REC.ORG_NAME,
                       DETAIL_ANONYMOUS_REC.USER_ID,
                       DETAIL_ANONYMOUS_REC.USER_NAME,
                       DETAIL_ANONYMOUS_REC.FULL_NAME,
                       DETAIL_ANONYMOUS_REC.EMPLOYEE_NUMBER,
                       DETAIL_ANONYMOUS_REC.FROM_EFFECTIVE_DATE_U,
                       DETAIL_ANONYMOUS_REC.TO_EFFECTIVE_DATE_U,
                       DETAIL_ANONYMOUS_REC.CREATED_BY,
                       DETAIL_ANONYMOUS_REC.CREATED_BY_NAME,
                       DETAIL_ANONYMOUS_REC.CREATION_DATE,
                       DETAIL_ANONYMOUS_REC.LAST_UPDATED_BY,
                       DETAIL_ANONYMOUS_REC.LAST_UPDATED_BY_NAME,
                       DETAIL_ANONYMOUS_REC.LAST_UPDATED_DATE, 
	                   DETAIL_ANONYMOUS_REC.RESPONSIBILITY_NAME, 
                       DETAIL_ANONYMOUS_REC.APPLICATION_NAME,
                       DETAIL_ANONYMOUS_REC.SECURITY_GROUP,
                       DETAIL_ANONYMOUS_REC.FROM_EFFECTIVE_DATE_R,
                       DETAIL_ANONYMOUS_REC.TO_EFFECTIVE_DATE_R,
                       DETAIL_ANONYMOUS_REC.ASSIGNED_BY, 
                       DETAIL_ANONYMOUS_REC.ASSIGNED_BY_NAME,
                       DETAIL_ANONYMOUS_REC.ASSIGNED_DATE,
                       DETAIL_ANONYMOUS_REC.ASSIGNMENT_UPDATED_BY,
                       DETAIL_ANONYMOUS_REC.ASSIGNMENT_UPDATED_BY_NAME, 
                       DETAIL_ANONYMOUS_REC.ASSIGNMENT_UPDATED_DATE);
		END LOOP;
		CLOSE C_DETAIL_ANONYMOUS;
		
		OPEN C_DETAIL_EMPLOYEE;
		LOOP
		  FETCH C_DETAIL_EMPLOYEE INTO DETAIL_EMPLOYEE_REC;
		  EXIT WHEN C_DETAIL_EMPLOYEE%NOTFOUND;
		  IF NOT CHECK_DUPLICATE(DETAIL_EMPLOYEE_REC.ORG_NAME) THEN
			idx := idx+1;
		    HEADER_EMPLOYEE_TAB(idx).ORGANIZATION_D := DETAIL_EMPLOYEE_REC.ORG_NAME;
			if DETAIL_EMPLOYEE_REC.ORG_TYPE is not null then
			    select meaning 
			    INTO HEADER_EMPLOYEE_TAB(idx).ORG_TYPE
                from fnd_lookup_values
                where lookup_type = 'ORG_TYPE'
                and lookup_code = DETAIL_EMPLOYEE_REC.ORG_TYPE;
			end if;
			HEADER_EMPLOYEE_TAB(idx).TAB_NAME := substr(DETAIL_EMPLOYEE_REC.ORG_NAME,1,31);
		  END IF;
          INSERT INTO XXUSER_RESPONSIBILITY_DETAIL(REQUEST_ID, ORGANIZATION, USER_ID, USER_NAME, FULL_NAME, EMPLOYEE_NUMBER, FROM_EFFECTIVE_DATE_U, TO_EFFECTIVE_DATE_U,
	                                         CREATED_BY, CREATED_BY_NAME, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATED_BY_NAME, LAST_UPDATED_DATE, 
	                                         RESPONSIBILITY_NAME, APPLICATION_NAME, SECURITY_GROUP, FROM_EFFECTIVE_DATE_R, TO_EFFECTIVE_DATE_R, ASSIGNED_BY, 
									         ASSIGNED_BY_NAME, ASSIGNED_DATE, ASSIGNMENT_UPDATED_BY, ASSIGNMENT_UPDATED_BY_NAME, ASSIGNMENT_UPDATED_DATE)
                VALUES(DETAIL_EMPLOYEE_REC.REQUEST_ID, 
                       DETAIL_EMPLOYEE_REC.ORG_NAME,
                       DETAIL_EMPLOYEE_REC.USER_ID,
                       DETAIL_EMPLOYEE_REC.USER_NAME,
                       DETAIL_EMPLOYEE_REC.FULL_NAME,
                       DETAIL_EMPLOYEE_REC.EMPLOYEE_NUMBER,
                       DETAIL_EMPLOYEE_REC.FROM_EFFECTIVE_DATE_U,
                       DETAIL_EMPLOYEE_REC.TO_EFFECTIVE_DATE_U,
                       DETAIL_EMPLOYEE_REC.CREATED_BY,
                       DETAIL_EMPLOYEE_REC.CREATED_BY_NAME,
                       DETAIL_EMPLOYEE_REC.CREATION_DATE,
                       DETAIL_EMPLOYEE_REC.LAST_UPDATED_BY,
                       DETAIL_EMPLOYEE_REC.LAST_UPDATED_BY_NAME,
                       DETAIL_EMPLOYEE_REC.LAST_UPDATED_DATE, 
	                   DETAIL_EMPLOYEE_REC.RESPONSIBILITY_NAME, 
                       DETAIL_EMPLOYEE_REC.APPLICATION_NAME,
                       DETAIL_EMPLOYEE_REC.SECURITY_GROUP,
                       DETAIL_EMPLOYEE_REC.FROM_EFFECTIVE_DATE_R,
                       DETAIL_EMPLOYEE_REC.TO_EFFECTIVE_DATE_R,
                       DETAIL_EMPLOYEE_REC.ASSIGNED_BY, 
                       DETAIL_EMPLOYEE_REC.ASSIGNED_BY_NAME,
                       DETAIL_EMPLOYEE_REC.ASSIGNED_DATE,
                       DETAIL_EMPLOYEE_REC.ASSIGNMENT_UPDATED_BY,
                       DETAIL_EMPLOYEE_REC.ASSIGNMENT_UPDATED_BY_NAME, 
                       DETAIL_EMPLOYEE_REC.ASSIGNMENT_UPDATED_DATE);
		END LOOP;
		CLOSE C_DETAIL_EMPLOYEE;
		
		FORALL x IN HEADER_EMPLOYEE_TAB.FIRST..HEADER_EMPLOYEE_TAB.LAST
		INSERT INTO XXUSER_RESPONSIBILITY_HEADER(REQUEST_ID, REPORT_RUN_DATE, GRE_NAME, INSTANCE_NAME, ORGANIZATION_D, ORGANIZATION_TYPE, TAB_NAME)
			                              VALUES(FND_GLOBAL.CONC_REQUEST_ID, 
			                                     SYSDATE, 
				                                 'Vision Corporation', 
				                                 SYS_CONTEXT('USERENV', 'DB_NAME'), 
				                                 HEADER_EMPLOYEE_TAB(x).ORGANIZATION_D, 
				                                 HEADER_EMPLOYEE_TAB(x).ORG_TYPE, 
				                                 HEADER_EMPLOYEE_TAB(x).TAB_NAME);
									 
	 /*INSERT INTO XXUSER_RESPONSIBILITY_DETAIL(REQUEST_ID, ORGANIZATION, USER_ID, USER_NAME, FULL_NAME, EMPLOYEE_NUMBER, FROM_EFFECTIVE_DATE_U, TO_EFFECTIVE_DATE_U,
	                                         CREATED_BY, CREATED_BY_NAME, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATED_BY_NAME, LAST_UPDATED_DATE, 
	                                         RESPONSIBILITY_NAME, APPLICATION_NAME, SECURITY_GROUP, FROM_EFFECTIVE_DATE_R, TO_EFFECTIVE_DATE_R, ASSIGNED_BY, 
									         ASSIGNED_BY_NAME, ASSIGNED_DATE, ASSIGNMENT_UPDATED_BY, ASSIGNMENT_UPDATED_BY_NAME, ASSIGNMENT_UPDATED_DATE)
	                                 SELECT DISTINCT
											 FND_GLOBAL.CONC_REQUEST_ID,
											 aou.name ORGANIZATION,
											 fuser.USER_ID, 
                                             fuser.USER_NAME, 
                                             per.FULL_NAME, 
                                             per.EMPLOYEE_NUMBER, 
                                             fuser.start_date FROM_EFFECTIVE_DATE_U, 
                                             fuser.end_date TO_EFFECTIVE_DATE_U, 
                                             fuser.CREATED_BY, 
                                             (SELECT Nvl(per.full_name, fuser1.user_name) 
                                              FROM   apps.fnd_user fuser1, 
                                                     apps.per_people_f per 
                                              WHERE  fuser1.employee_id = per.person_id(+) 
                                              AND Trunc(SYSDATE) BETWEEN per.effective_start_date(+) 
                                                                         AND 
                                                                         per.effective_end_date (+) 
                                              AND fuser1.user_id = fuser.created_by) CREATED_BY_NAME, 
                                             fuser.CREATION_DATE, 
                                             fuser.LAST_UPDATED_BY, 
                                            (SELECT Nvl(per.full_name, fuser2.user_name) 
                                             FROM   apps.fnd_user fuser2, 
                                                    apps.per_people_f per 
                                             WHERE  fuser2.employee_id = per.person_id(+) 
                                             AND Trunc(SYSDATE) BETWEEN per.effective_start_date(+) 
                                                                        AND 
                                                                        per.effective_end_date (+) 
                                             AND fuser2.user_id = fuser.last_updated_by) LAST_UPDATED_BY_NAME, 
                                             fuser.last_update_date LAST_UPDATED_DATE, 
                                             frt.RESPONSIBILITY_NAME, 
                                             app.APPLICATION_NAME,
											 sg.security_group_name SECURITY_GROUP, 
                                             gd.start_date FROM_EFFECTIVE_DATE_R, 
                                             gd.end_date TO_EFFECTIVE_DATE_R, 
                                             gd.created_by ASSIGNED_BY, 
                                             (SELECT Nvl(per.full_name, fuser3.user_name) 
                                              FROM   apps.fnd_user fuser3, 
                                                     apps.per_people_f per 
                                              WHERE  fuser3.employee_id = per.person_id(+) 
                                              AND Trunc(SYSDATE) BETWEEN per.effective_start_date(+) 
                                                                         AND 
                                                                         per.effective_end_date (+) 
                                              AND fuser3.user_id = gd.created_by) ASSIGNED_BY_NAME, 
                                             gd.creation_date ASSIGNED_DATE, 
                                             gd.last_updated_by ASSIGNMENT_UPDATED_BY, 
                                             (SELECT Nvl(per.full_name, fuser4.user_name) 
                                              FROM   apps.fnd_user fuser4, 
                                                     apps.per_people_f per 
                                              WHERE  fuser4.employee_id = per.person_id(+) 
                                              AND Trunc(SYSDATE) BETWEEN per.effective_start_date(+) 
                                                                         AND 
                                                                         per.effective_end_date (+) 
                                              AND fuser4.user_id = gd.last_updated_by) ASSIGNMENT_UPDATED_BY_NAME, 
                                              gd.last_update_date ASSIGNMENT_UPDATED_DATE 
                                      FROM   apps.fnd_user_resp_groups_direct gd, 
                                             apps.fnd_security_groups_tl sg, 
                                             apps.fnd_user fuser, 
                                             apps.per_people_f per,
                                             per_all_assignments_f paa,
                                             hr_all_organization_units aou,											 
                                             apps.fnd_responsibility_tl frt, 
                                             apps.fnd_application_tl app 
                                      WHERE  gd.security_group_id = sg.security_group_id 
                                      AND fuser.user_id = gd.user_id 
									  AND aou.organization_id = paa.organization_id
                                      AND paa.person_id = per.person_id
                                      AND fuser.employee_id = per.person_id(+) 
                                      AND Trunc(SYSDATE) BETWEEN per.effective_start_date(+)
									                             AND      
																 per.effective_end_date (+) 
                                      AND gd.responsibility_id = frt.responsibility_id 
                                      AND frt.LANGUAGE = 'US' 
                                      AND frt.application_id = app.application_id 
                                      AND frt.LANGUAGE = 'US' 
									  ; */
    COMMIT;	
    RETURN(TRUE);
  end BeforeReportTrigger;
END XXEDP_USER_RESP_ASGNMNT_PKG;
/