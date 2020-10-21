# sqlite-enron
this 60-megabyte sqlite-database contains a smaller subset of 10,000 emails
from the enron-email-database at https://archive.org/details/enron.db.7z
suitable for testing wasm-sqlite in browsers

#### how was the sqlite-file enron.small.db created?
1. download/unzip the full-sqlite-file from https://archive.org/details/enron.db.7z and rename it `.enron.db`
2. in this repo's script `enron.createdb.sql`, uncomment the database-creation section
3. run shell-command:
`rm -f enron.small.db && sqlite3 enron.small.db ".read enron.createdb.sql" && ll enron.small.db`
