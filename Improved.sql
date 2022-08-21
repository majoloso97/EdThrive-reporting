Select 
    CombinedPivot.dtmonth
    round(avg(CombinedPivot.activeResponsePerHr),2), 
    round(avg(CombinedPivot.affirmativesPerHr),2),
    round(avg(CombinedPivot.correctivesPerHr),2),
    round(avg(CombinedPivot.academicPerHr * EstTime),2),
    round(avg(CombinedPivot.behavioralPerHr * EstTime),2),
    round(avg(CombinedPivot.harshPerHr * EstTime),2),
    round(avg(CombinedPivot.cannotDeterminePerHr * EstTime),2)
from
    (Select
		Pivot.coachingId,
        Pivot.dtmonth,
        IF(Coaching.elapsedTime > 0, (3600/Coaching.elapsedTime), (3600/Coaching.observationLength)) as EstTime,
        SUM(Pivot.interactionactivestudentresponse) AS activeResponsePerHr,
        SUM(Pivot.interactionacademicaffirmative) + SUM(Pivot.interactionbehavioralaffirmative) AS affirmativesPerHr
        SUM(Pivot.interactionacademiccorrective) + SUM(Pivot.interactionbehavioralcorrective) AS correctivesPerHr,
        SUM(Pivot.interactionacademicaffirmative) + SUM(Pivot.interactionacademiccorrective) AS academicPerHr,
        SUM(Pivot.interactionbehavioralaffirmative) + SUM(Pivot.interactionbehavioralcorrective) AS behavioralPerHr,
        SUM(Pivot.interactionharsh) AS harshPerHr,
        SUM(Pivot.interactioncannotdetermine) AS cannotDeterminePerHr
        from Coaching
        inner join
            (Select
                T.coachingId,
                T.dtmonth,
                MAX(CASE WHEN T.type = 'interactionactivestudentresponse' THEN t.amount ELSE NULL END) AS interactionactivestudentresponse,
                MAX(CASE WHEN T.type = 'interactionacademicaffirmative' THEN t.amount ELSE NULL END) AS interactionacademicaffirmative,
                MAX(CASE WHEN T.type = 'interactionbehavioralaffirmative' THEN t.amount ELSE NULL END) AS interactionbehavioralaffirmative,
                MAX(CASE WHEN T.type = 'interactionacademiccorrective' THEN t.amount ELSE NULL END) AS interactionacademiccorrective,
                MAX(CASE WHEN T.type = 'interactionbehavioralcorrective' THEN t.amount ELSE NULL END) AS interactionbehavioralcorrective,
                MAX(CASE WHEN T.type = 'interactionharsh' THEN t.amount ELSE NULL END) AS interactionharsh,
                MAX(CASE WHEN T.type = 'interactioncannotdetermine' THEN t.amount ELSE NULL END) AS interactioncannotdetermine
            from
                (select CoachingData.coachingId, CoachingData.type, SUM(CoachingData.count) as amount,
                CONCAT(YEAR(CoachingData.dt), '-', MONTH(CoachingData.dt)) AS dtmonth
                from CoachingData
                where CoachingData.type in ('interactionactivestudentresponse',
                                            'interactionacademicaffirmative',
                                            'interactionbehavioralaffirmative',
                                            'interactionacademiccorrective',
                                            'interactionbehavioralcorrective',
                                            'interactionharsh',
                                            'interactioncannotdetermine')
                -- and CoachingData.dt between '2022-05-01 16:37:14' and '2022-05-31 06:00:00'
                group by CoachingData.coachingId, CoachingData.type, dtmonth) as T
            group by T.coachingId, T.dtmonth)
        AS Pivot
        ON Coaching.id = Pivot.coachingId
        WHERE Coaching.orgId = 1000163
        and Coaching.type = 'observestudentengage'
        and Coaching.state = 'concluded'
        and Coaching.status = 'active'
        -- and (Coaching.startTime between '2022-05-01 06:00:00' and '2022-05-31 06:00:00')
        -- and Coaching.whoId in (2334, 4352)
        group by Pivot.coachingId, Pivot.dtmonth
    ) AS CombinedPivot
group by CombinedPivot.dtmonth