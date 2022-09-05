import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('NounCoin', () => {
  let origin: SignerWithAddress
  let treasury: SignerWithAddress
  let minter1: SignerWithAddress
  let minter2: SignerWithAddress
  let minter3: SignerWithAddress
  let coin: Contract
  const COIN_URI = 'https://nouns.express/_/api/tokens/{id}.json'

  it('Create NOUN COIN with getters', async () => {
    [origin, treasury, minter1, minter2, minter3] = await ethers.getSigners()
    const HuntDescriptor = await ethers.getContractFactory('HuntDescriptor')
    const NounCoin = await ethers.getContractFactory('NounCoin')

    const hunt = await HuntDescriptor.deploy(2)

    coin = await NounCoin.deploy(
      hunt.address,
      COIN_URI,
      treasury.address,
      origin.address
    )

    const balance = await coin.balanceOf(origin.address, 1)
    expect(balance.toNumber()).to.equal(0)
  })

  it('Mints NOUN COIN', async () => {
    await coin.mint(minter1.address, 1, { value: parseEther('0.001') })
    await coin.mint(minter2.address, 2, { value: parseEther('5') })

    const balance1 = await coin.balanceOf(minter1.address, 1)
    const balance2 = await coin.balanceOf(minter2.address, 2)

    expect(balance1).to.equal(parseEther('0.001'))
    expect(balance2).to.equal(parseEther('10'))

    const amount3 = ethers.utils.parseEther('1')
    await coin.mint(minter3.address, 1, { value: amount3 })
    const balance3 = await coin.balanceOf(minter3.address, 1)

    expect(balance3).to.equal(parseEther('2'))

    console.log({ balance1, balance2, balance3 })
  })
})
