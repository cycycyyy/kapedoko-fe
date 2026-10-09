import { readFileSync } from 'node:fs'
import { describe, expect, test } from 'bun:test'
import { sameHoursEveryDay } from './hours'
import {
  canCommitCrate,
  crateTally,
  keptImportDrafts,
  parseCafeImportCsv,
  parseCsvRecords,
  stampReadyTickets,
  stampTicket,
} from './cafe-csv-import'

const hours = JSON.stringify(sameHoursEveryDay('08:00', '20:00'))

function csv(rows: string[]) {
  return ['name,address,latitude,longitude,hours_json,contact_number,google_place_id', ...rows].join('\n')
}

describe('cafe CSV import crate', () => {
  test('parses quoted hours JSON with commas', () => {
    const records = parseCsvRecords(`name,hours_json\nResonate,"{""mon"":{""kind"":""open""}}"\n`)
    expect(records[1]?.[1]).toContain('"kind"')
  })

  test('builds tickets and holds the write until every cafe is stamped', () => {
    const tickets = parseCafeImportCsv(csv([
      `"Resonate Coffee","25 Bronze Street, Marikina",14.6507,121.1127,"${hours.replaceAll('"', '""')}",0936 943 7956,ChIJ1`,
      `"Needs Hours","25 Bronze Street, Marikina",14.6507,121.1130,,,ChIJ2`,
    ]))
    expect(tickets).toHaveLength(2)
    expect(tickets[0]?.decision).toBe('undecided')
    expect(tickets[1]?.decision).toBe('skip')
    expect(tickets[1]?.blockReason).toBe('missing_hours')
    expect(canCommitCrate(tickets)).toBe(false)

    const kept = stampReadyTickets(tickets)
    expect(kept[0]?.decision).toBe('keep')
    expect(canCommitCrate(kept)).toBe(true)
    expect(keptImportDrafts(kept)).toEqual([{
      name: 'Resonate Coffee',
      address: '25 Bronze Street, Marikina',
      latitude: 14.6507,
      longitude: 121.1127,
      hours: sameHoursEveryDay('08:00', '20:00'),
      contact_number: '0936 943 7956',
    }])
  })

  test('flags a nearby same-name shop as already listed', () => {
    const tickets = parseCafeImportCsv(csv([
      `"Resonate Coffee","Bronze Street, Marikina",14.6507,121.1127,"${hours.replaceAll('"', '""')}",,ChIJ1`,
    ]), [{
      name: 'Resonate Coffee',
      latitude: 14.65075,
      longitude: 121.11272,
    }])
    expect(tickets[0]?.blockReason).toBe('duplicate_nearby')
    expect(tickets[0]?.decision).toBe('undecided')
    expect(stampTicket(tickets, tickets[0]!.key, 'keep')[0]?.decision).toBe('keep')
  })

  test('rejects a file without the cafe columns', () => {
    expect(() => parseCafeImportCsv('title,city\nHello,Marikina\n')).toThrow(/KapeDoko cafe CSV/)
  })

  test('reads the Marikina export and holds the write until every cafe is stamped', () => {
    const raw = readFileSync(new URL('../../data/imports/marikina-places-cafes.csv', import.meta.url), 'utf8')
    const tickets = parseCafeImportCsv(raw)
    expect(tickets).toHaveLength(72)
    expect(tickets.every((ticket) => ticket.name && ticket.address)).toBe(true)
    expect(canCommitCrate(tickets)).toBe(false)
    expect(crateTally(tickets)).toMatchObject({
      keep: 0,
      skip: 4,
      undecided: 68,
      blocked: 4,
    })

    const stamped = stampReadyTickets(tickets)
    expect(canCommitCrate(stamped)).toBe(true)
    expect(keptImportDrafts(stamped)).toHaveLength(68)
    expect(keptImportDrafts(stamped)[0]).toMatchObject({
      name: '1821 Café',
      address: '28 J.P. Laurel Sr, Cor Mt Everest, San Roque, Marikina',
    })
  })

  test('counts a mixed crate', () => {
    const tickets = parseCafeImportCsv(csv([
      `"Keep Me","25 Bronze Street, Marikina",14.6507,121.1127,"${hours.replaceAll('"', '""')}",,a`,
      `"Skip Me","25 Bronze Street, Marikina",14.6507,121.1135,,,b`,
    ]))
    const stamped = stampTicket(tickets, 'a:1', 'keep')
    expect(crateTally(stamped)).toMatchObject({
      total: 2,
      keep: 1,
      skip: 1,
      undecided: 0,
      blocked: 1,
    })
  })
})
