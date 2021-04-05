# 群公告 #
# 2021-01-20题目
表结构如下：
Student(Sid,Sname,Sage,Ssex) 学生表 sid为key
Course(Cid,Cname,Tid) 课程表 cid 为key
SC(Sid,Cid,score) 成绩表 (sid, cid) 为key
Teacher(Tid,Tname) 教师表 tid为key

43）查询两门以上不及格课程的同学的学号及其平均成绩；
44）查询“004”课程分数小于60，按分数降序排列的同学学号和姓名；
45）查询“化学课”成绩第11-20名学生学号和姓名（注：不用考虑分数相同的情况）

-- 43
select Sid
     , avg(score) as avg_score
from SC
where Sid in (
  select Sid
  from SC 
  where score < 60
  group by 1
  having count(distinct Cid) >= 2)
group by 1

-- 44
select sc.Sid as Sid
     , Sname
from SC
join Student s on s.Sid = sc.Sid
where Cid = '004' and score < 60
order by score desc

--45
select Sid
       , Sname
from(
      select sc.Sid as Sid
        , s.Sname as Sname 
        , rank() over (order by sc.score desc) as ranking
      from SC sc
      join Course c on c.Cid = sc.Cid
      join Student s on s.Sid = sc.Sid
      where Cname = '化学' ) a
where ranking >= 11 and ranking <= 20





