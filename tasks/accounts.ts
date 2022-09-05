import chalk from 'chalk'
import { task } from 'hardhat/config'

task('accounts', 'Prints the list of accounts', async (_, { ethers }) => {
  const accounts = await ethers.getSigners()

  const balances = await Promise.all(
    accounts.map(async (a) => await a.getBalance().then((n) => ((n as any) / 1e18)))
  )

  accounts.forEach((account, idx) => {
    console.log(`${chalk.bold(account.address)}: ${balances[idx]}`)
  })
})
