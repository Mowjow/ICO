const helper = require('./helper');
const should = helper.should;
const config = require('../migrations/config.json');

const MowjowCrowdsale = artifacts.require('MowjowCrowdsale'),
    MowjowToken = artifacts.require('MowjowToken'),
    EarlyContribStrategy = artifacts.require("EarlyContribStrategy"),
    PreIcoStrategy = artifacts.require("PreIcoStrategy"),
    TrancheStrategy = artifacts.require('TrancheStrategy'),
    FinalizableMowjow = artifacts.require('FinalizableMowjow'),
    MultiSigMowjow = artifacts.require('MultiSigMowjow'),
    MowjowFunds = artifacts.require('MowjowFunds');

const setupParams = {
    pre_ico: {
        bonus: 100,
        amount: 80000,
        rate: 40000
    },
    tranche_strategy: {
        bonus: [100, 100],
        amount: [80000, 80000],
        rate: [40000, 40000]
    },
    early_contributors: {
        bonus: 100,
        amount: 80000,
        rate: 40000
    },
    crowdsale: {
        rate: 1,
        cap: 2,
    }
};


contract('PreIcoStrategy', function ([_, investor, wallet, purchaser]) {

    before(async function () {
        await helper.advanceBlock();

        const rate = 40000;
        const startTime = helper.latestTime() + helper.duration.weeks(1),
            endTime = startTime + helper.duration.weeks(8),
            afterEndTime = endTime + helper.duration.weeks(8);

        this.crowdsaleParams = {
            rate: 1,
            cap: helper.ether(1),
            start_time: startTime,
            end_time: endTime,
            after_end_time: afterEndTime
        };

        this.val = helper.ether(1).mul(0.5);
        this.PURCHASE_EVENT = 'Purchase';
        this.expectedTokenAmount = new helper.BigNumber(rate).mul(2);
    });

    beforeEach(async function () {

        const preIcoStrategy = await PreIcoStrategy.new(
            setupParams.pre_ico.bonus,
            setupParams.pre_ico.amount,
            setupParams.pre_ico.rate
        );

        const trancheStrategy = await TrancheStrategy.new(
            setupParams.tranche_strategy.bonus,
            setupParams.tranche_strategy.amount,
            setupParams.tranche_strategy.rate
        );

        const mowjowFunds = await MowjowFunds.deployed();
        const finalizableMowjow = await FinalizableMowjow.new(mowjowFunds.address);

        await preIcoStrategy.setEndDate(this.crowdsaleParams.end_time);
        await trancheStrategy.setEndDate(this.crowdsaleParams.end_time);

        const earlyContribStrategy = await EarlyContribStrategy.new(
            config.early_contributors.bonus, config.early_contributors.token_cap,
            config.early_contributors.rate
        );

        this.mowjowCrowdsale = await MowjowCrowdsale.new(
            this.crowdsaleParams.start_time, this.crowdsaleParams.end_time,
            this.crowdsaleParams.rate, wallet, this.crowdsaleParams.cap,
            earlyContribStrategy.address, preIcoStrategy.address,
            trancheStrategy.address, finalizableMowjow.address
        );

        const mowjowCrowdsaleAddress = this.mowjowCrowdsale.address;
        await preIcoStrategy.setCrowdsaleAddress(mowjowCrowdsaleAddress);
        await trancheStrategy.setCrowdsaleAddress(mowjowCrowdsaleAddress);
        await earlyContribStrategy.setCrowdsaleAddress(mowjowCrowdsaleAddress);

        const tokenInstance = await this.mowjowCrowdsale.token();
        this.token = await MowjowToken.at(tokenInstance);

    });

    describe('payments in pre ico for whitelist investors', function () {

        it('should add investor to whitelist successfully and permission for invest', async function () {
            await this.mowjowCrowdsale.addWhitelistInvestors(investor);
            const {logs} = await this.mowjowCrowdsale.buyTokens(investor, {value: this.val, from: purchaser});
            const event = logs.find(e => e.event === this.PURCHASE_EVENT);
            should.exist(event);
            event.args.beneficiary.should.be.bignumber.equal(investor);
            event.args.value.should.be.bignumber.equal(this.val);
        });

        it('should test % bonus for  whitelist investor ', async function () {
            let fundValue = helper.ether(1);
            await this.mowjowCrowdsale.addWhitelistInvestors(purchaser);

            const {logs} = await this.mowjowCrowdsale.buyTokens(purchaser, {value: fundValue, from: purchaser});
            const event = logs.find(e => e.event === this.PURCHASE_EVENT);
            should.exist(event);
            event.args.beneficiary.should.be.bignumber.equal(purchaser);
            event.args.value.should.be.bignumber.equal(fundValue);
            event.args.amount.should.be.bignumber.equal(this.expectedTokenAmount);

            const balance = await this.token.balanceOf(purchaser);
            balance.should.be.bignumber.equal(this.expectedTokenAmount);
        });
    })

});
