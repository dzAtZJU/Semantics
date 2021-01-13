const {ObjectId} = require('mongodb')

class TheSearchNext {
    db
    userId
    placeId
    conditionPreferences
    conditionIds
    conditionId2Operator
    conditionId2Places
    constructor(client, arg) {
        this.db = client.db('Semantics')
        this.userId = "5f7230d2a370285602303f7e"
        this.placeId = arg.placeId
        this.conditionPreferences = arg.conditions

        this.conditionIds = arg.conditions.map(
            (item) => item.conditionId
        )

        this.conditionId2Operator = new Map()
        this.conditionId2Places = new Map()
        this.conditionPreferences.forEach(item=>{
            this.conditionId2Operator.set(item.conditionId,item.nextOperator)
            this.conditionId2Places.set(item.conditionId, [])
        })
    }

    processBetter(placeScores, targetScore) {
        let betterPlaceIndex
        if(placeScores.some((item, index) => {
            betterPlaceIndex = index - 1
            return item.score === targetScore
        })) {
            return betterPlaceIndex === -1 ? undefined : betterPlaceIndex
        } else {
            return undefined
        }
    }

    processNoWorse(placeScores, targetScore) {
        let worsePlaceIndex
        if(placeScores.some((item, index) => {
            worsePlaceIndex = index
            return item.score === targetScore + 1
        })) {
            return worsePlaceIndex - 1
        } else {
            return placeScores.length - 1
        }
    }

    processNoMatter(placeScores, targetScore) {
        return placeScores.length - 1
    }

    async processConditionRank(item) {
        const placeScores =  await this.db.collection("PlaceScore").find({_id:{$in:item.placeScoreList}}).sort({score:1}).toArray()
        let targetScore
        if(placeScores.length === 0 || !placeScores.some(item => {
            targetScore = item.score
            return item.placeId === this.placeId
        })) {
            return
        }

        let ceil
        const operator = this.conditionId2Operator.get(item.conditionId)
        if(operator === 0) {
            ceil = this.processBetter(placeScores, targetScore)
        } else if(operator === 1) {
            ceil = this.processNoWorse(placeScores, targetScore)
        } else if(operator === 2) {
            ceil = this.processNoMatter(placeScores, targetScore)
        } else if(operator !== undefined){
            throw new Error('condition operator must in [0, 2]')
        }

        if(ceil !== undefined) {
            if(!this.conditionId2Places.has(item.conditionId)) {
                this.conditionId2Places.set(item.conditionId, [])
            }
            const newPlaceIdsAndBacker = {
                placeIds: placeScores.slice(0, ceil+1).map(item => { return item.placeId })
                    .filter(item => { return item !== this.placeId}),
                backer: item.ownerId
            }
            this.conditionId2Places.set(item.conditionId, this.conditionId2Places.get(item.conditionId).concat(newPlaceIdsAndBacker))
        }
    }

    placeIdsSatisfyingAllConditions() {
        let placeIdSet = new Set()
        let index = 0
        this.conditionId2Places.forEach((value, conditionId)=>{
            const newPlaceIds = new Set(value.flatMap(item=>item.placeIds))
            if(index === 0){
                placeIdSet = newPlaceIds
                index += 1
            } else {
                placeIdSet.forEach(placeId=>{
                    if(!newPlaceIds.has(placeId)) {
                        placeIdSet.delete(placeId)
                    }
                })
            }
        })
        return placeIdSet
    }

    async searchNext() {
        const individual = await this.db.collection("Individual").findOne({_id: this.userId})
        const blockList = individual.blockedIndividuals
        const conditionRanks = await this.db.collection("ConditionRank").find({ownerId:{$ne: this.userId}, conditionId:{$in:this.conditionIds}, placeScoreList:{$exists:true}}).toArray()

        for (let index = 0; index < conditionRanks.length; index++) {
            const item = conditionRanks[index]

            if (blockList !== undefined) {
                const block = blockList.find(block => block.conditionId === item.conditionId)
                if(block !== undefined && block.individuals.includes(item.ownerId)) {
                    continue
                }
            }
            await this.processConditionRank(item)
        }


        const placeIdSet = this.placeIdsSatisfyingAllConditions()

        let placeId2ConditionId2Backers = new Map()
        this.conditionId2Places.forEach((value, conditionId)=>{
            value.forEach(placeIdsAndBacker=>{
                placeIdsAndBacker.placeIds.forEach(placeId=>{
                    if(placeIdSet.has(placeId)) {
                        if(!placeId2ConditionId2Backers.has(placeId)) {
                            placeId2ConditionId2Backers.set(placeId, new Map())
                        }
                        if(!placeId2ConditionId2Backers.get(placeId).has(conditionId)) {
                            placeId2ConditionId2Backers.get(placeId).set(conditionId, [])
                        }
                        placeId2ConditionId2Backers.get(placeId).set(conditionId, placeId2ConditionId2Backers.get(placeId).get(conditionId).concat([placeIdsAndBacker.backer]))
                    }
                })
            })
        })


        let backerIds = []
        placeId2ConditionId2Backers.forEach((item)=>{
            item.forEach(i=>{
                backerIds = backerIds.concat(i)
            })
        })
        const backers = await this.db.collection("Individual").find({_id:{$in:backerIds}}).toArray()
        const backerId2Title = new Map()
        backers.forEach(item=>{
            backerId2Title.set(item._id, item.title)
        })

        let result = []
        placeId2ConditionId2Backers.forEach((conditionId2Backers,placeId)=>{
            let conditions = []
            conditionId2Backers.forEach((backerIds, conditionId)=>{
                conditions.push({
                    "id": conditionId,
                    "backers": backerIds.map(backerId=>{
                        return {"id":backerId, "title":backerId2Title.get(backerId)}
                    })
                })
            })

            result.push({
                "placeId": placeId,
                "conditions": conditions
            })
        })
        return {"places": result}
    }
}


module.exports = TheSearchNext

