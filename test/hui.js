const Hui = artifacts.require("Hui");
const truffleAssert = require('truffle-assertions');

contract("Hui", acc => {
  let instance;
  beforeEach('setup contract instance', async () => {
    instance = await Hui.new();
  })

  it('print the number of members', async () => {
    const memberNum = await instance.getMembers();
    assert.equal(memberNum, 0);
  })

  it('print the transaction', async () => {
    const result = await instance.signUp('duc');
    truffleAssert.prettyPrintEmittedEvents(result);
  })

  it('emit after create member', async () => {
    const result = await instance.signUp('duc');
    truffleAssert.eventEmitted(result, 'NewMember', (ev) => {
      console.log('Name: ', ev._name)
      return ev._name == 'duc';
    })
  })

  it('return member length after create', async () => {
    const result = await instance.signUp('duc');
    truffleAssert.eventEmitted(result, 'NewMember', async (ev) => {
      let mem = await instance.getMembers();
      return assert.equal(mem, 1);
    })
  })
});
