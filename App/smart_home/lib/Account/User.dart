

class User{
  String id, name, picUrl;

  User(){
    name = '';
    id = '';
    picUrl = '';
  }

  void set(String name, String id, String picUrl){
    this.name = name;
    this.id = id;
    this.picUrl = picUrl;
  }

  void update(User user){
    name = user.getName();
    id = user.getId();
    picUrl = user.getPicture();
  }

  bool isEqual(User user){
    return (name == user.getName() && id == user.getId() && picUrl == user.getPicture());
  }

  void clear(){
    name = '';
    id = '';
    picUrl = '';
  }

  String getName(){
    return name;
  }

  String getId(){
    return id;
  }

  String getPicture(){
    return picUrl;
  }
}