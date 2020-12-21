int aa[10];

int main(int argc, int argv[]) {
	int MonaWallet;
	int KeqingWallet;

	KeqingWallet = 10000;
	MonaWallet = 0;

	MonaWallet = MonaEarn(KeqingWallet/10, MonaWallet);
	
	return 0;
}

int MonaEarn(int sallery, int MonaWallet)
{
	return sallery + MonaWallet;
}
