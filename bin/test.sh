cat lib/header.litcoffee lib/event.litcoffee lib/model.litcoffee lib/collection.litcoffee lib/syncer.litcoffee > out/smackbone.litcoffee
coffee --compile out/smackbone.litcoffee
coffee --compile test/*.litcoffee
