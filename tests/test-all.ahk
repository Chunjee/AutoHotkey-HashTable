SetBatchLines, -1
#SingleInstance, force
#NoTrayIcon
#Include %A_ScriptDir%\..\export.ahk
#Include %A_ScriptDir%\..\node_modules
#Include unit-testing.ahk\export.ahk

assert := new unittesting()
table := new hashtable()

; create
assert.group("create")
assert.label("add values")
assert.true(table.create(1, "bill"))
assert.true(table.create(2, "ted"))

assert.label("add existing value")
assert.true(table.create(2, "ted"))

assert.label("create - add object")



; read
assert.group("read")
assert.label("find values")
assert.test(table.read(1), "bill")
assert.test(table.read(2), "ted")
assert.test(table.read(3), "")



; update
assert.group("update")
assert.label("find values")
assert.true(table.update(1, "Bill"))
assert.test(table.read(1), "Bill")


; delete
assert.group("delete")
assert.label("remove keys")
assert.true(table.delete(1))
assert.false(table.delete(1))


;; Display test results in GUI
assert.fullReport()
assert.writeTestResultsToFile()

ExitApp
