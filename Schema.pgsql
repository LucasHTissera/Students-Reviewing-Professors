CREATE TABLE "students" (
    "id" SERIAL,
    "First name" VARCHAR(60) NOT NULL,
    "Last name" VARCHAR(60) NOT NULL,
    "User name" VARCHAR(40) NOT NULL UNIQUE,
    "Password" VARCHAR(40) NOT NULL,
    "Enrollment date" DATE NOT NULL,
    "Graduation date" DATE DEFAULT CURRENT_DATE,
    "Gradutated" BOOLEAN,
    PRIMARY KEY("id")
);


CREATE TABLE "subjects" (
    "id" SERIAL,
    "name" VARCHAR(60) NOT NULL,
    "Brief description" VARCHAR(150) NOT NULL,
    "Being taught" BOOLEAN,
    PRIMARY KEY("id")
);

CREATE TABLE "classes" (
    "id" SERIAL PRIMARY KEY,
    "Name" VARCHAR(60) NOT NULL,
    "Classroom number" SMALLINT NOT NULL,
    "Subject_id" INTEGER NOT NULL,
    "Starting date" DATE NOT NULL,
    "End date" DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY ("Subject_id")
        REFERENCES "subjects"("id")
);

CREATE TABLE "professors" (
    "id" SERIAL,
    "First name" VARCHAR(60) NOT NULL,
    "Last name" VARCHAR(60) NOT NULL,
    "User name" VARCHAR(40) NOT NULL UNIQUE,
    "Password" VARCHAR(40) NOT NULL,
    "Employment date" DATE NOT NULL,
    "Employment termination date" DATE DEFAULT CURRENT_DATE,
    "Employed" BOOLEAN,
    PRIMARY KEY("id")
);

CREATE TABLE "teaching_class" (
    "id" BIGSERIAL PRIMARY KEY,
    "professor_id" SERIAL NOT NULL,
    "class_id" SERIAL NOT NULL,
    FOREIGN KEY ("professor_id") REFERENCES "professors"("id"),
    FOREIGN KEY ("class_id") REFERENCES "classes"("id")
);

CREATE TABLE "attending_class" (
    "id" BIGSERIAL PRIMARY KEY,
    "student_id" SERIAL NOT NULL,
    "class_id" SERIAL NOT NULL,
    FOREIGN KEY ("student_id") REFERENCES "students"("id"),
    FOREIGN KEY ("class_id") REFERENCES "classes"("id")
);

CREATE TABLE "class_subject" (
    "id" BIGSERIAL PRIMARY KEY,
    "subject_id" SERIAL NOT NULL,
    "class_id" SERIAL NOT NULL,
    FOREIGN KEY ("subject_id") REFERENCES "subjects"("id"),
    FOREIGN KEY ("class_id") REFERENCES "classes"("id")
);

CREATE TYPE "rating" AS ENUM('1','2','3','4','5')

DROP VIEW "past_reviews";

DROP TABLE "reviews";

CREATE TABLE "reviews" (
    "id" BIGSERIAL PRIMARY KEY,
    "student_id" SERIAL NOT NULL,
    "lecturer_id" SERIAL NOT NULL,
    "practice_teacher_1_id" SERIAL NOT NULL, -- There will always be at least one practice teacher
    "practice_teacher_2_id" SERIAL,
    "practice_teacher_3_id" SERIAL,
    "class_id" SERIAL NOT NULL,
    "Opinion of the class" RATING NOT NULL,
    "Opinion of the lecturer" RATING NOT NULL,
    "Opinion of the practice teachers" RATING NOT NULL,
    "Usefulness of the class" RATING NOT NULL,
    "Comments" VARCHAR(500),
    FOREIGN KEY ("student_id") REFERENCES "students"("id"),
    FOREIGN KEY ("class_id") REFERENCES "classes"("id")
);


CREATE VIEW "classes_professors_subjects" AS
SELECT "classes"."Name" AS "Class", "classes"."Classroom number", "subjects"."name" AS "Subject",
"professors"."First name" AS "Professor's first name",
"professors"."Last name" AS "Professor's last name"
FROM "classes"
JOIN "teaching_class" ON "classes"."id" = "teaching_class"."class_id"
JOIN "professors" ON "professors"."id" = "teaching_class"."professor_id"
JOIN "subjects" ON "classes"."Subject_id" = "subjects"."id"
WHERE "End date" <= CURRENT_DATE;

CREATE VIEW "past_reviews" AS
SELECT "classes"."Name" AS "Class", "professors"."Last name" AS "Professor's last name",
"professors"."First name" AS "Professor's first name", "subjects"."name" AS "Subject",
"reviews"."Opinion of the class", "reviews"."Opinion of the lecturer", 
"reviews"."Opinion of the practice teachers",
"reviews"."Usefulness of the class", "reviews"."Comments"
FROM "reviews"
JOIN "classes" ON "reviews"."class_id" = "classes"."id"
JOIN "teaching_class" ON "reviews"."class_id" = "teaching_class"."class_id"
JOIN "professors" ON "professors"."id" = "teaching_class"."professor_id"
JOIN "subjects" ON "classes"."Subject_id" = "subjects"."id"
ORDER BY "Class", "Professor's last name";

CREATE VIEW "students_class" AS
SELECT "classes"."Classroom number", "subjects"."name" AS "Subject",
"students"."Last name" AS "Student's Last name",
"students"."First name" AS "Student's first name"
FROM "classes"
JOIN "attending_class" ON "attending_class"."class_id" = "classes"."id"
JOIN "students" ON "students"."id" = "attending_class"."student_id"
JOIN "subjects" ON "classes"."Subject_id" = "subjects"."id";

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE "new_student";

CREATE PROCEDURE "new_student" (
    First_name VARCHAR(60),
    Last_name VARCHAR(60),
    User_name VARCHAR(40),
    Pass VARCHAR(40),
    Enrollment_date DATE,
    Graduation_date DATE,
    Gradutated BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "students" ("First name", "Last name", "User name", "Password", "Enrollment date", "Graduation date", "Gradutated") 
    VALUES (First_name, Last_name, User_name, Pass, Enrollment_date, Graduation_date, Gradutated);
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', User_name, Pass);
    EXECUTE format('GRANT SELECT ON teaching_class TO %I', User_name);
    EXECUTE format('GRANT SELECT ON classes_professors_subjects TO %I', User_name);
    EXECUTE format('GRANT SELECT ON past_reviews TO %I', User_name);
    EXECUTE format('GRANT SELECT, INSERT ON reviews TO %I', User_name);
END; $$;


CALL new_student('John', 'Doe', 'jdoe', 'password123', '2024-09-01', '2024-09-02', FALSE);

SELECT * FROM "students";

/*  SELECT routine_name, routine_definition
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE'
AND specific_schema = 'public'; 

SELECT * FROM pg_catalog.pg_user; */

/* SELECT grantee, table_catalog, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'jdoe'; */


/* DROP PROCEDURE "remove_student"; */

/* CREATE PROCEDURE "remove_student" (
    User_name VARCHAR(40)
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "students" WHERE "User name" = User_name;
    EXECUTE format('REVOKE SELECT, INSERT ON "reviews" FROM %I', User_name);
    EXECUTE format('REVOKE SELECT ON teaching_class TO %I', User_name);
    EXECUTE format('REVOKE SELECT ON classes_professors_subjects TO %I', User_name);
    EXECUTE format('REVOKE SELECT ON past_reviews TO %I', User_name);
    EXECUTE format('DROP USER %I', User_name);
END;
$$; */


/* CALL remove_student('jdoe') */

/* DROP PROCEDURE "new_professor"; */

CREATE PROCEDURE "new_professor" (
    First_name VARCHAR(60),
    Last_name VARCHAR(60),
    User_name VARCHAR(40),
    Pass VARCHAR(40),
    Employment_date DATE,
    Employment_termination_date DATE,
    Employed BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "professors" ("First name", "Last name", "User name", "Password", "Employment date", "Employment termination date", "Employed") 
    VALUES (First_name, Last_name, User_name, Pass, Employment_date, Employment_termination_date, Employed);
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', User_name, Pass);
    EXECUTE format('GRANT SELECT ON past_reviews TO %I', User_name);
    EXECUTE format('GRANT SELECT ON students_class TO %I', User_name);
    EXECUTE format('GRANT INSERT ON teaching_class TO %I', User_name);
END;
$$;

/* DROP PROCEDURE "remove_professor";

CREATE PROCEDURE "remove_professor" (
    User_name VARCHAR(40)
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "professors" WHERE "User name" = User_name;
    EXECUTE format('REVOKE SELECT ON past_reviews FROM %I', User_name);
    EXECUTE format('REVOKE SELECT ON students_class TO %I', User_name);
    EXECUTE format('REVOKE INSERT ON teaching_class TO %I', User_name);
    EXECUTE format('DROP USER %I', User_name);
END;
$$; */

CREATE FUNCTION check_student_in_class()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM attending_class
        WHERE class_id = NEW.class_id
        AND student_id = NEW.student_id
    ) THEN
        RAISE EXCEPTION 'Student % isnt attending class %', NEW.student_id, NEW.class_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION check_professor_in_class()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM teaching_class
        WHERE class_id = NEW.class_id
        AND professor_id = NEW.lecturer_id
    ) THEN
        RAISE EXCEPTION 'Lecturer % isnt teaching class %', NEW.lecturer_id, NEW.class_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM teaching_class
        WHERE class_id = NEW.class_id
        AND professor_id = NEW.practice_teacher_1_id
    ) THEN
        RAISE EXCEPTION 'Practice teacher % isnt teaching class %', NEW.practice_teacher_1_id, NEW.class_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM teaching_class
        WHERE class_id = NEW.class_id
        AND professor_id = NEW.practice_teacher_2_id
    ) THEN
        RAISE EXCEPTION 'Practice teacher % isnt teaching class %', NEW.practice_teacher_2_id, NEW.class_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM teaching_class
        WHERE class_id = NEW.class_id
        AND professor_id = NEW.practice_teacher_3_id
    ) THEN
        RAISE EXCEPTION 'Practice teacher % isnt teaching class %', NEW.practice_teacher_3_id, NEW.class_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "new_review" BEFORE INSERT ON "reviews" FOR EACH ROW
EXECUTE FUNCTION check_student_in_class()
EXECUTE FUNCTION check_professor_in_class();

