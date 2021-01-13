const TheSearchNext = require('./TheSearchNext')
const {EJSON} = require('bson')
const {MongoClient} = require('mongodb')

const uri = "mongodb+srv://paper:yeweiya@cluster1.3ium9.mongodb.net/Semantics?retryWrites=true&w=majority"

let client

beforeAll(() => {
    client = new MongoClient(uri, {useUnifiedTopology: true})
    return client.connect()
        .then(() => {
            return checkConnection(client)
        }).then((count) => {
            console.log("connected to db")
        })
})

afterAll(() => {
    return client.close()
})

test('one condition better', async () => {
    const arg = {
        "placeId": "Tims Coffee (Daxue Road Branch)",
        "conditions": [
            {
                "conditionId": "卫生间",
                "nextOperator": {
                    "$numberInt": "0"
                }
            }
        ]
    }
    const argBSON = EJSON.parse(JSON.stringify(arg))
    const algo = new TheSearchNext(client, argBSON)
    const result = await algo.searchNext()
    expect(result.places.length).toEqual(1)
})


test('one condition better, the other no worse', async () => {
    const arg = {
        "placeId": "Tims Coffee (Daxue Road Branch)",
        "conditions": [
            {
                "conditionId": "空间设计",
                "nextOperator": {
                    "$numberInt": "0"
                }
            }
        ]
    }

    const argBSON = EJSON.parse(JSON.stringify(arg))
    const algo = new TheSearchNext(client, argBSON)
    const result = await algo.searchNext()
    expect(result.places.length).toEqual(0)
})

test('one condition better, the other no worse', async () => {
    const arg = {
        "placeId": "Tims Coffee (Daxue Road Branch)",
        "conditions": [
            {
                "conditionId": "网络",
                "nextOperator": {
                    "$numberInt": "1"
                }
            }
        ]
    }

    const argBSON = EJSON.parse(JSON.stringify(arg))
    const algo = new TheSearchNext(client, argBSON)
    const result = await algo.searchNext()
    expect(result.places.length).toEqual(2)
})

test('one condition better, the other no worse', async () => {
    const arg = {
        "placeId": "Tims Coffee (Daxue Road Branch)",
        "conditions": [
            {
                "conditionId": "卫生间",
                "nextOperator": {
                    "$numberInt": "1"
                }
            }
        ]
    }

    const argBSON = EJSON.parse(JSON.stringify(arg))
    const algo = new TheSearchNext(client, argBSON)
    const result = await algo.searchNext()
    expect(result.places.length).toEqual(2)
})

test('one condition better, the other no worse', async () => {
    const arg = {
        "placeId": "Tims Coffee (Daxue Road Branch)",
        "conditions": [
            {
                "conditionId": "卫生间",
                "nextOperator": {
                    "$numberInt": "0"
                }
            },
            {
                "conditionId": "空间设计",
                "nextOperator": {
                    "$numberInt": "0"
                }
            }
        ]
    }

    const argBSON = EJSON.parse(JSON.stringify(arg))
    const algo = new TheSearchNext(client, argBSON)
    const result = await algo.searchNext()
    expect(result.places.length).toEqual(0)
})

test('one condition better, the other no worse', async () => {
    const arg = {
        "placeId": "Tims Coffee (Daxue Road Branch)",
        "conditions": [
            {
                "conditionId": "卫生间",
                "nextOperator": {
                    "$numberInt": "0"
                }
            },
            {
                "conditionId": "网络",
                "nextOperator": {
                    "$numberInt": "1"
                }
            }
        ]
    }

    const argBSON = EJSON.parse(JSON.stringify(arg))
    const algo = new TheSearchNext(client, argBSON)
    const result = await algo.searchNext()
    expect(result.places.length).toEqual(1)
})

function checkConnection(client) {
    return client.db("Semantics").collection("Individual").countDocuments()
}