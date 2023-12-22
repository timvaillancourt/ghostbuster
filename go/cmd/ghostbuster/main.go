package main

import (
	"context"
	"database/sql"
	"log"
	"sync"
	"time"

	"github.com/brianvoe/gofakeit"
	_ "github.com/go-sql-driver/mysql"
)

const maxWriters = 4

type testRow struct {
	firstname string
	lastname  string
	message   string
}

func newTestRow() testRow {
	return testRow{
		firstname: gofakeit.FirstName(),
		lastname:  gofakeit.LastName(),
		message:   gofakeit.Sentence(4),
	}
}

func (row *testRow) Insert(db *sql.DB) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*3)
	defer cancel()

	_, err := db.ExecContext(ctx, `INSERT INTO test.testtable (firstname, lastname, message) VALUES(?, ?, ?)`,
		row.firstname,
		row.lastname,
		row.message,
	)
	return err
}

func main() {
	db, err := sql.Open("mysql", "root:@tcp(127.0.0.1:3306)/test")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

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

	var count int64
	for count < 100000 {
		count++
		rowsChan <- newTestRow()
	}
	log.Printf("wrote %d rows, exiting", count)

	close(rowsChan)
	wg.Wait()
}
