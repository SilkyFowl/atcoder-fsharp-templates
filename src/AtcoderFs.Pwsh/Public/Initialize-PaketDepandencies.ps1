function Initialize-PaketDepandencies {
    paket init
    dotnet new accpacket --force
    paket update
}