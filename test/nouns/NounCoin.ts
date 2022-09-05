import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('NounCoin', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let coin: Contract
  let descriptor: Contract
  const COIN_URI = 'https://nouns.express/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const MockDescriptor = await ethers.getContractFactory('MockDescriptor')
    const NounCoin = await ethers.getContractFactory('NounCoin')
    descriptor = await MockDescriptor.deploy(2)
    coin = await NounCoin.deploy(COIN_URI, descriptor.address)
  })

  it('Create NOUN COIN with getters', async () => {
    const desc = await coin.descriptor()
    const ampl = await coin.ampl()
    expect(desc).to.equal(descriptor.address)
    expect(ampl).to.equal(20000)
  })

  it('Origin claim', async () => {
    const value = parseEther('1')
    const claim1 = parseEther('0.05')
    const claim2 = parseEther('0.06')
    const balance1 = await bob.getBalance()

    await coin.mint(alice.address, 0, 0, { value })
    await coin.originClaim(bob.address, claim1)
    const balance2 = await bob.getBalance()

    expect(balance1.add(claim1)).to.equal(balance2)
    await expect(
      coin.originClaim(bob.address, claim2)
    ).to.revertedWith('Claimable: origin claim is too large')
    await coin.originClaim(bob.address, claim1)
  })

  it('Fails to origin claim when too large', async () => {
    const value = parseEther('1')
    const claim1 = parseEther('0.1000000000001')
    await coin.mint(alice.address, 0, 0, { value })
    await expect(
      coin.originClaim(bob.address, claim1)
    ).to.revertedWith('Claimable: origin claim is too large')
  })

  it('Mints 2 to 1', async () => {
    const value = parseEther('1')
    await coin.mint(alice.address, 0, 0, { value })
    await coin.mint(bob.address, 1, 0, { value })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(bob.address, 1)

    expect(balanceA).to.equal(value)
    expect(balanceB).to.equal(value.mul(2))
  })

  it('Mints both then one', async () => {
    const value = parseEther('1')

    await coin.mintBatch(alice.address, [0, 1], 0, { value })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(alice.address, 1)

    expect(balanceA).to.equal(value.div(2))
    expect(balanceB).to.equal(value.div(2))

    await coin.mint(alice.address, 0, 0, { value })

    const balanceA1 = await coin.balanceOf(alice.address, 0)
    expect(balanceA1).to.equal(value.add(parseEther('0.5')))
  })

  it('Mints more of one then the other', async () => {
    const value1 = parseEther('1')
    const value2 = parseEther('0.5')

    await coin.mint(alice.address, 0, 0, { value: value1 })
    await coin.mint(alice.address, 1, 0, { value: value2 })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(alice.address, 1)

    expect(balanceA).to.equal(value1)
    expect(balanceB).to.equal(value2.mul(2)) // discount because other was minted
  })

  it('Mints less of one then the other', async () => {
    const value1 = parseEther('0.5')
    const value2 = parseEther('1')

    await coin.mint(alice.address, 0, 0, { value: value1 })
    await coin.mint(alice.address, 1, 0, { value: value2 })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(alice.address, 1)

    expect(balanceA).to.equal(value1)
    expect(balanceB).to.equal(value2.mul(2)) // discount because other was minted
  })

  it('Fails to mint with incorrect number of heads', async () => {
    const value = parseEther('1')

    await expect(
      coin.mint(alice.address, 3, 0, { value })
    ).to.revertedWith('Not enough heads')
  })

  it('Empty conversion rates', async () => {
    const value = parseEther('1')
    const rate1 = await coin.conversionRate(0, value)
    const rate2 = await coin.conversionRate(1, value)
    expect(rate1).to.equal(value) // 1 = 1
    expect(rate2).to.equal(value) // 1 = 1
  })

  it('Fails to mint zero coins', async () => {
    const amount = parseEther('0')

    await expect(
      coin.mint(alice.address, 0, 0, { value: amount })
    ).to.revertedWith('NounCoin: must mint some coins')

    await expect(
      coin.mintBatch(alice.address, [0, 1], 0, { value: amount })
    ).to.revertedWith('NounCoin: must mint some coins')
  })
})
