表结构如下：
Student(Sid,Sname,Sage,Ssex) 学生表
Course(Cid,Cname,Tid) 课程表
SC(Sid,Cid,score) 成绩表
Teacher(Tid,Tname) 教师表

4） 查询“001”课程比“002”课程成绩高的所有学生的学号（注：学生同时选修了这两门课）；
5） 查询“003”课程的学生成绩情况，要求输出学生学号，姓名和成绩情况（大于或等于80表示优秀，大于或等于60表示及格，小于60分表示不及格）；
6） 查询平均成绩大于60分的同学的学号、姓名和平均成绩；

10）查询学过“001”并且也学过“002”课程的同学的学号、姓名；
11）查询学过“李四”老师所教的所有课的同学的学号、姓名；
12）查询所有课程成绩小于60分的同学的学号、姓名；

13）查询选修了所有选修课程的同学的学号和姓名；
14）查询没有学全所有课的同学的学号、姓名；
15）查询至少有一门课与学号为“001”的同学所学相同的同学的学号和姓名；

16）查询至少学过学号为“001”同学所有一门课的其他同学学号和姓名；
17）查询和“002”号的同学学习的课程完全相同的其他同学学号和姓名；
18）按平均成绩从低到高显示所有学生的“语文”、“数学”、“英语”三门的课程成绩，按如下形式显示：学生ID,语文,数学,英语,有效课程数,有效平均分；

-- 16
select s.Sid, s.Sname
from Student s 
join SC sc on s.Sid = sc.Sid
where sc.Cid in (
   select sc.Cid as Cid
   from Student s 
   join SC sc on s.Sid = sc.Sid
   where s.Sid = '001'
   group by 1
)

-- 17
select s.Sid
      , max(s.Sname)
      , count(distinct sc.Cid) as course_num
from Student s 
join SC sc on s.Sid = sc.Sid
where sc.Cid in (
   select sc.Cid as Cid
   from Student s 
   join SC sc on s.Sid = sc.Sid
   where s.Sid = '002'
   group by 1
) a
group by 1 
having course_num = (
   select count(distinct sc.Cid) course_num
   from Student s 
   join SC sc on s.Sid = sc.Sid
   where s.Sid = '002')

-- 18
select s.Sid as Sid
      , max(if(c.Cname='语文', sc.score, 0)) as '语文'
      , max(if(c.Cname='数学', sc.score, 0)) as '数学'
      , max(if(c.Cname='英语', sc.score, 0)) as '英语'
      , count(distinct if(sc.score is null, null, c.Cid)) as '有效课程数'
      , avg(ifnull(sc.score),0) as '有效平均分'
from Student s 
join SC sc on s.Sid = sc.Sid
join Course c on sc.Cid = c.Cid
group by 1












-- 13
select Sid, Sname
from(
   select s.Sid as Sid
      , max(s.Sname) as Sname
      , count(distinct sc.Cid) as course_num
   from Student s 
   join SC sc on s.Sid = sc.Sid
   group by 1   
) a
where course_num = (select count(distinct Cid) from Course)


-- 14
select Sid, Sname
from(
   select s.Sid as Sid
      , max(s.Sname) as Sname
      , count(distinct sc.Cid) as course_num
   from Student s 
   join SC sc on s.Sid = sc.Sid
   join Teacher t on c.Tid = t.Tid 
   group by 1   
) a
where course_num < (select count(distinct Cid) from Course)

-- 15

select s.Sid as Sid
      , max(s.Sname) as Sname
from Student s 
join SC sc on s.Sid = sc.Sid
where sc.Cid in (   
   select sc.Cid as Cid
   from Student s 
   join SC sc on s.Sid = sc.Sid
   where Sid = '001'
)
  
