import { ethers } from 'hardhat'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

describe('Origin', () => {
  let contract: Contract
  let origin1: SignerWithAddress
  let origin2: SignerWithAddress

  beforeEach(async () => {
    [origin1, origin2] = await ethers.getSigners()
    const Origin = await ethers.getContractFactory('Origin')
    contract = await Origin.deploy(origin1.address)
  })

  it('Create origin with getters', async () => {
    const address = await contract.originAddress()
    const provenance = await contract.originProvenance()
    expect(address).to.equal(origin1.address)
    expect(provenance).to.equal(ethers.constants.AddressZero)
  })

  it('Move origin', async () => {
    await contract.moveOrigin(origin2.address)
    const address = await contract.originAddress()
    expect(address).to.equal(origin2.address)
  })

  it('Relinquish origin', async () => {
    await contract.relinquishOrigin()
    const address = await contract.originAddress()
    const provenance = await contract.originProvenance()
    expect(address).to.equal(ethers.constants.AddressZero)
    expect(provenance).to.equal(origin1.address)
  })

  it('Fails to move origin', async () => {
    await expect(
      contract.connect(origin2).moveOrigin(origin2.address)
    ).to.revertedWith('Caller is not the ORIGIN')
  })

  it('Fails to relinquish origin', async () => {
    await expect(
      contract.connect(origin2).relinquishOrigin()
    ).to.revertedWith('Caller is not the ORIGIN')
  })
})
