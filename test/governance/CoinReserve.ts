import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('CoinReserve', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let reserve: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  it('Create coin reserve', async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Reserve = await ethers.getContractFactory('MockReserve')
    reserve = await Reserve.deploy(BASE_URI)

    const supply = await reserve.totalSupply()
    const balance = await reserve.treasuryBalance()
    const address = await reserve.treasurerAddress()
    const supply1 = await reserve.totalSupplyOf(1)
    const rate = await reserve.conversionRate(1, parseEther('1'))

    expect(supply).to.equal(0)
    expect(balance).to.equal(0)
    expect(supply1).to.equal(0)
    expect(rate).to.equal(1)
    expect(address).to.equal(origin.address)
  })

  it('Mint coins to Alice and Bob', async () => {
    const amountA = parseEther(`${Math.random()}`)
    const amountB = parseEther(`${Math.random()}`)

    await reserve.mint(alice.address, 1, 0, { value: amountA })
    await reserve.mint(bob.address, 2, 0, { value: amountB })

    const totalSupply = await reserve.totalSupply()

    const balanceA = await reserve.balanceOf(alice.address, 1)
    const balanceB = await reserve.balanceOf(bob.address, 2)

    const supplyA = await reserve.totalSupplyOf(1)
    const supplyB = await reserve.totalSupplyOf(2)

    expect(balanceA).to.equal(amountA)
    expect(balanceB).to.equal(amountB)
    expect(supplyA).to.equal(amountA)
    expect(supplyB).to.equal(amountB)
    expect(totalSupply).to.equal(supplyA.add(supplyB))
  })

  it('Fails to mint zero coins', async () => {
    const amount = parseEther('0')
    await expect(
      reserve.mint(alice.address, 1, 0, { value: amount })
    ).to.revertedWith('CoinTreasury: must mint some coins')
  })
})
