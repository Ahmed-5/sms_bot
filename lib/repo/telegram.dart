class Telegram {
  String body;
  String address;
  bool isCurrentUser;
  int unixDate;

  Telegram({this.body, this.address, this.isCurrentUser, this.unixDate}) {
    this.address = processAddress(this.address);
  }

  String processAddress(String address) {
    if (address.startsWith("0")) {
      return "+249" + address.substring(1);
    }
    if (address.startsWith("249")) {
      return "+" + address;
    } else {
      return address;
    }
  }
}
