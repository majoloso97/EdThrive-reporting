select
    SUM(AR.amount) as activeResponsePerHr,
    SUM(AFI.amount) as affirmativesPerHr,
    SUM(CFI.amount) as correctivesPerHr,
	ROUND(AVG(IF(elapsedTime > 0,
                AF.amount * (3600/elapsedTime),
                AF.amount * (3600/observationLength))), 2) as academicPerHr,
    ROUND(AVG(IF(elapsedTime > 0,
                BF.amount * (3600/elapsedTime),
                BF.amount * (3600/observationLength))), 2) as behavioralPerHr,
    ROUND(AVG(IF(elapsedTime > 0,
                HF.amount * (3600/elapsedTime),
                HF.amount * (3600/observationLength))), 2) as harshPerHr,
    ROUND(AVG(IF(elapsedTime > 0,
                UF.amount * (3600/elapsedTime),
                UF.amount * (3600/observationLength))), 2) as cannotDeterminePerHr
                    from Coaching
                        left join
                            (select
                                CoachingData.coachingId,
                                SUM(CoachingData.count) as amount
                                from CoachingData
                                    where CoachingData.type in ('interactionactivestudentresponse')
                                    AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                    group by CoachingData.coachingId) AS AR
                                        on Coaching.id = AR.coachingId
                        left join
                        (
                            select CoachingData.coachingId, SUM(CoachingData.count) as amount
                            from CoachingData
                                where CoachingData.type in ('interactionacademicaffirmative', 'interactionbehavioralaffirmative')
                                AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                group by CoachingData.coachingId) AS AFI
                            on Coaching.id = AFI.coachingId
                        left join (
                            select CoachingData.coachingId, SUM(CoachingData.count) as amount
                            from CoachingData
                                where CoachingData.type in ('interactionacademiccorrective', 'interactionbehavioralcorrective')
                                AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                group by CoachingData.coachingId) AS CFI
                                    on Coaching.id = CFI.coachingId
                        left join (
                            select CoachingData.coachingId, SUM(CoachingData.count) as amount
                                from CoachingData
                                    where CoachingData.type in ('interactionacademicaffirmative', 'interactionacademiccorrective')
                                    AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                    group by CoachingData.coachingId) AS AF
                                        on Coaching.id = AF.coachingId
                        left join (select CoachingData.coachingId, SUM(CoachingData.count) as amount
                                from CoachingData
                                    where CoachingData.type in ('interactionbehavioralaffirmative','interactionbehavioralcorrective')
                                    AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                    group by CoachingData.coachingId) AS BF
                                        on Coaching.id = BF.coachingId
                        left join (select CoachingData.coachingId, SUM(CoachingData.count) as amount
                                from CoachingData
                                    where CoachingData.type in ('interactionharsh')
                                    AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                    group by CoachingData.coachingId) AS HF
                                        on Coaching.id = HF.coachingId
                        left join (select CoachingData.coachingId, SUM(CoachingData.count) as amount
                                from CoachingData
                                    where CoachingData.type in ('interactioncannotdetermine')
                                    AND CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                                    group by CoachingData.coachingId) AS UF
                                        on Coaching.id = UF.coachingId
                        where Coaching.orgId = 1000163 and Coaching.type = 'observestudentengage' and
								Coaching.state = 'concluded' and
                                (Coaching.startTime between '2022-05-01 06:00:00' and '2022-05-31 06:00:00') and
                                Coaching.status = 'active';