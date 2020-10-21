.bail on
/*
-- read database-schema
-- sqlite3 .enron.db ".read enron.createdb.sql"
-- SELECT `name`, `sql` FROM `sqlite_master`;
-- employeelist|CREATE TABLE `employeelist` (
--   `eid` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
-- ,  `firstName` varchar(31) NOT NULL DEFAULT ''
-- ,  `lastName` varchar(31) NOT NULL DEFAULT ''
-- ,  `Email_id` varchar(31) NOT NULL DEFAULT ''
-- ,  `Email2` varchar(31) DEFAULT NULL
-- ,  `Email3` varchar(31) DEFAULT NULL
-- ,  `EMail4` varchar(31) DEFAULT NULL
-- ,  `folder` varchar(31) NOT NULL DEFAULT ''
-- ,  `status` varchar(50) DEFAULT NULL
-- ,  UNIQUE (`Email_id`)
-- )
-- sqlite_autoindex_employeelist_1|
-- sqlite_sequence|CREATE TABLE sqlite_sequence(name,seq)
-- message|CREATE TABLE `message` (
--   `mid` integer NOT NULL DEFAULT '0'
-- ,  `sender` varchar(127) NOT NULL DEFAULT ''
-- ,  `date` datetime DEFAULT NULL
-- ,  `message_id` varchar(127) DEFAULT NULL
-- ,  `subject` text
-- ,  `body` text
-- ,  `folder` varchar(127) NOT NULL DEFAULT ''
-- ,  PRIMARY KEY (`mid`)
-- )
-- messages_ft_content|CREATE TABLE 'messages_ft_content'(docid INTEGER PRIMARY KEY, 'c0subject', 'c1body')
-- messages_ft_segments|CREATE TABLE 'messages_ft_segments'(blockid INTEGER PRIMARY KEY, block BLOB)
-- messages_ft_segdir|CREATE TABLE 'messages_ft_segdir'(level INTEGER,idx INTEGER,start_block INTEGER,leaves_end_block INTEGER,end_block INTEGER,root BLOB,PRIMARY
-- KEY(level, idx))
-- sqlite_autoindex_messages_ft_segdir_1|
-- messages_ft_docsize|CREATE TABLE 'messages_ft_docsize'(docid INTEGER PRIMARY KEY, size BLOB)
-- messages_ft_stat|CREATE TABLE 'messages_ft_stat'(id INTEGER PRIMARY KEY, value BLOB)
-- recipientinfo|CREATE TABLE `recipientinfo` (
--   `rid` integer NOT NULL DEFAULT '0'
-- ,  `mid` integer  NOT NULL DEFAULT '0'
-- ,  `rtype` text  DEFAULT NULL
-- ,  `rvalue` varchar(127) DEFAULT NULL
-- ,  `dater` datetime DEFAULT NULL
-- ,  PRIMARY KEY (`rid`)
-- ,  FOREIGN KEY (mid) REFERENCES message(mid)
-- )
-- referenceinfo|CREATE TABLE `referenceinfo` (
--   `rfid` integer NOT NULL DEFAULT '0'
-- ,  `mid` integer NOT NULL DEFAULT '0'
-- ,  `reference` text
-- ,  PRIMARY KEY (`rfid`)
-- ,  FOREIGN KEY (mid) REFERENCES message(mid)
-- )
-- idx_message_sender|CREATE INDEX "idx_message_sender" ON "message" (`sender`)
-- messages_ft|CREATE VIRTUAL TABLE messages_ft USING fts4(subject, body)
*/


/*
-- create database-schema
-- rm -f enron.small.db; sqlite3 enron.small.db ".read enron.createdb.sql"
CREATE TABLE `employeelist` (
  `eid` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `firstName` varchar(31) NOT NULL DEFAULT ''
,  `lastName` varchar(31) NOT NULL DEFAULT ''
,  `Email_id` varchar(31) NOT NULL DEFAULT ''
,  `Email2` varchar(31) DEFAULT NULL
,  `Email3` varchar(31) DEFAULT NULL
,  `EMail4` varchar(31) DEFAULT NULL
,  `folder` varchar(31) NOT NULL DEFAULT ''
,  `status` varchar(50) DEFAULT NULL
,  UNIQUE (`Email_id`)
);
CREATE TABLE `message` (
  `mid` integer NOT NULL DEFAULT '0'
,  `sender` varchar(127) NOT NULL DEFAULT ''
,  `date` datetime DEFAULT NULL
,  `message_id` varchar(127) DEFAULT NULL
-- ,  `subject` text
-- ,  `body` text
,  `folder` varchar(127) NOT NULL DEFAULT ''
,  PRIMARY KEY (`mid`)
);
CREATE TABLE `recipientinfo` (
  `rid` integer NOT NULL DEFAULT '0'
,  `mid` integer  NOT NULL DEFAULT '0'
,  `rtype` text  DEFAULT NULL
,  `rvalue` varchar(127) DEFAULT NULL
,  `dater` datetime DEFAULT NULL
,  PRIMARY KEY (`rid`)
,  FOREIGN KEY (mid) REFERENCES message(mid)
);
CREATE TABLE `referenceinfo` (
  `rfid` integer NOT NULL DEFAULT '0'
,  `mid` integer NOT NULL DEFAULT '0'
,  `reference` text
,  PRIMARY KEY (`rfid`)
,  FOREIGN KEY (mid) REFERENCES message(mid)
);
CREATE INDEX "idx_message_sender" ON "message" (`sender`);
CREATE VIRTUAL TABLE messages_ft USING fts4(subject, body);

-- insert tables
ATTACH DATABASE '.enron.db' AS archive1;
-- employeelist
-- message
-- recipientinfo
-- referenceinfo
-- message_ft
SELECT 'archive1.employeelist', COUNT(*) FROM archive1.employeelist;
SELECT 'archive1.message', COUNT(*) FROM archive1.message;
SELECT 'archive1.recipientinfo', COUNT(*) FROM archive1.recipientinfo;
SELECT 'archive1.referenceinfo', COUNT(*) FROM archive1.referenceinfo;
SELECT 'archive1.messages_ft', COUNT(*) FROM archive1.messages_ft;

INSERT INTO message SELECT * FROM
    (
    SELECT
        message.mid,
        message.sender,
        message.date,
        message.message_id,
        -- message.subject,
        -- message.body,
        message.folder
    FROM
    (
    SELECT DISTINCT message.mid
    FROM archive1.message
    INNER JOIN archive1.recipientinfo ON recipientinfo.mid = message.mid
    INNER JOIN archive1.referenceinfo ON referenceinfo.mid = message.mid
    ) AS tmp1
    INNER JOIN archive1.message ON message.mid = tmp1.mid
    ORDER BY tmp1.mid
    LIMIT 10000
    ) AS tmp1;

INSERT INTO employeelist SELECT * FROM archive1.employeelist;
INSERT INTO recipientinfo SELECT
        tmp1.rid,
        tmp1.mid,
        tmp1.rtype,
        tmp1.rvalue,
        tmp1.dater
    FROM message
    LEFT JOIN archive1.recipientinfo AS tmp1 ON tmp1.mid = message.mid
    ORDER BY tmp1.rid;
INSERT INTO referenceinfo SELECT
        tmp1.rfid,
        tmp1.mid,
        tmp1.reference
    FROM message
    LEFT JOIN archive1.referenceinfo AS tmp1 ON tmp1.mid = message.mid
    ORDER BY tmp1.rfid;
INSERT INTO messages_ft (
    rowid, subject, body
)
SELECT
        tmp1.mid, tmp1.subject, tmp1.body
    FROM message
    INNER JOIN archive1.message AS tmp1 ON tmp1.mid = message.mid
    ORDER BY tmp1.mid;
VACUUM;
SELECT 'employeelist', COUNT(*) FROM employeelist;
SELECT 'message', COUNT(*) FROM message;
SELECT 'recipientinfo', COUNT(*) FROM recipientinfo;
SELECT 'referenceinfo', COUNT(*) FROM referenceinfo;
SELECT 'messages_ft', COUNT(*) FROM messages_ft;
*/

-- read tables
-- sqlite3 enron.small.db ".read enron.createdb.sql"
SELECT COUNT(*) FROM messages_ft
INNER JOIN recipientinfo ON recipientinfo.mid = messages_ft.rowid
INNER JOIN referenceinfo ON referenceinfo.mid = messages_ft.rowid
WHERE body MATCH 'futures';
