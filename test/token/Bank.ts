import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('Bank', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let reserve: Contract
  let bank: Contract
  let coin1: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  before(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Reserve = await ethers.getContractFactory('MockLedger')
    const Bank = await ethers.getContractFactory('MockBank')
    reserve = await Reserve.deploy(BASE_URI)
    bank = await Bank.deploy(reserve.address)
  })

  it('Deploy token', async () => {
    await bank.deployToken(1, 'COIN1')
    const address = await bank.canonicalToken(1)

    const Token = await ethers.getContractFactory('Token')
    coin1 = await Token.attach(address)

    expect(await coin1.name()).to.equal('COIN1')
  })

  it('Transfers coin', async () => {
    const amountA = parseEther(`${Math.random()}`)
    await reserve.mint(alice.address, 1, 0, { value: amountA })

    await coin1.connect(alice).transfer(bob.address, amountA)

    const balanceA = await coin1.balanceOf(alice.address)
    const balanceB = await coin1.balanceOf(bob.address)

    console.log({
      balanceA, balanceB
    })
  })
})
