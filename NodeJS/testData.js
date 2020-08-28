// let a = {
//     "conditions": [
//     {
//         "conditionId": BSON.ObjectId("5f4401062dea587f87f3c4ef"),
//         "nextOperator": 2
//     },
//     {
//         "conditionId": BSON.ObjectId("5f4401062dea587f87f3c4f0"),
//         "nextOperator": 2
//     },
//     {
//         "conditionId": BSON.ObjectId("5f4401062dea587f87f3c4ee"),
//         "nextOperator": 2
//     }],
//     "placeId": BSON.ObjectId("5f4401132dea587f87f3c4f7")
// }
//
// return db.collection("PlaceScore").find({_id:{$in:item.placeScoreList}}).toArray().then(placeScores=>{
//     return placeScores.some(item => item.placeId == placeId)
// })
//
// exports = function(arg){
//     const Bluebird = require("bluebird")
//
//     let db = context.services.get("mongodb-atlas").db("Semantics")
//
//     let conditions = arg.conditions
//     let conditionIds = conditions.map(
//         (info) => info.conditionId
//     )
//     return db.collection("ConditionRank").find({ownerId:{$ne: context.user.id}, conditionId:{$in:conditionIds}}).toArray().then(conditionRanks=>{
//         let placeId = 1//arg.placeId
//         return Bluebird.Promise.filter(conditionRanks, function(item, index, len){
//             return true
//         }).then(items=>{
//             return items.length
//         })
//     })
//
// }
console.log([1,2].map(i=>[1,2]))