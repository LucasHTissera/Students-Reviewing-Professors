-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

INSERT INTO "professors"("First name", "Last name", "User name", "Password", "Employment date", "Employed")
VALUES ('Jan', 'Doe', 'Jandoe', 'pass', '2024-07-16', 'True');

INSERT INTO "subjects"("name", "Brief description", "Being taught")
VALUES ('physics', 'test', 'True');

INSERT INTO "classes"("Name", "Classroom number", "Subject_id", "Starting date", "End date")
VALUES ('physics', '101', '2', '2024-07-01', '2024-07-15');

INSERT INTO "class_subject"("subject_id", "class_id")
VALUES ('2', '4');

INSERT INTO "teaching_class"("professor_id", "class_id")
VALUES ('2', '4');

INSERT INTO "students"("First name", "Last name", "User name", "Password", "Enrollment date", "Gradutated")
VALUES ('mary', 'sue', 'msue', 'pass', '2024-07-01', 'True');

INSERT INTO "reviews"("student_id", "lecturer_id", "practice_teacher_1_id", "class_id", "Opinion of the class", "Opinion of the lecturer",
"Opinion of the practice teachers", "Usefulness of the class", "Comments")
VALUES ('10', '2', '3', '4', '5', '5', '5', '5', 'the class was ok');

SELECT * FROM "past_reviews";

SELECT * FROM "classes_professors_subjects";

CALL new_student('John', 'Doe', 'jdoe', 'password123', '2024-09-01', '2024-09-02', FALSE);

CALL remove_student('jdoe')


