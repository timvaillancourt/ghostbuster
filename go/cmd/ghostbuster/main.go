package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/brianvoe/gofakeit"
	_ "github.com/go-sql-driver/mysql"
)

var (
	maxRows    int64  = 250000
	maxWriters int    = 4
	host       string = "primary"
	port       int    = 3306
	database   string = "test"
	username   string = "root"
	password   string
)

type testRow struct {
	firstname string
	lastname  string
	message   string
}

func newTestRow() testRow {
	return testRow{
		firstname: gofakeit.FirstName(),
		lastname:  gofakeit.LastName(),
		message:   gofakeit.Sentence(5),
	}
}

func (row *testRow) Insert(db *sql.DB) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*3)
	defer cancel()

	_, err := db.ExecContext(ctx, `INSERT INTO testtable (firstname, lastname, message) VALUES(?, ?, ?)`,
		row.firstname,
		row.lastname,
		row.message,
	)
	return err
}

func main() {
	flag.StringVar(&host, "host", host, "mysql host")
	flag.IntVar(&port, "port", port, "mysql port")
	flag.StringVar(&username, "username", username, "mysql username")
	flag.StringVar(&password, "password", password, "mysql password")
	flag.StringVar(&database, "database", database, "mysql database")
	flag.IntVar(&maxWriters, "writers", maxWriters, "number of writers")
	flag.Int64Var(&maxRows, "max-rows", maxRows, "number of rows to write, 0 == run forever")
	flag.Parse()

	db, err := sql.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
		username, password, host, port, database,
	))
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatal(err)
	}

	var wg sync.WaitGroup
	rowsChan := make(chan testRow, maxWriters)

	var writers int
	for writers < maxWriters {
		wg.Add(1)
		go func(wg *sync.WaitGroup, rowsChan chan testRow, writer int) {
			defer wg.Done()

			log.Printf("started insert worker %d", writer)
			var count int
			for row := range rowsChan {
				if err := row.Insert(db); err != nil {
					log.Printf("ERROR: could not insert row: %+v", err)
					continue
				}
				count++
			}

			log.Printf("stopped insert worker %d, wrote %d rows", writer, count)
		}(&wg, rowsChan, writers)
		writers++
	}

	defer func() {
		close(rowsChan)
		wg.Wait()
	}()

	var rows int64
	for rows < maxRows {
		rows++
		rowsChan <- newTestRow()
	}
	log.Printf("wrote %d rows, exiting", rows)
}
