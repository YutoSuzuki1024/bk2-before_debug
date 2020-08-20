class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy

  has_many :follower, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy #フォロー取得
  has_many :followed, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy #フォロワー取得
  #Userテーブル同士の多対多の関係を簡潔にするため、中間テーブルである"Relationship"テーブルを作り、その中身をfollowerとfollowedで分けている
  #foreign_keyは外部キーで、「userのid」とforeign_keyが合致するものを"follower_id","followed_id"に持ってこれる(=どのuserがfollower,followedなのか)

  has_many :following_user, through: :follower, source: :followed #自分がフォローしている人
  has_many :follower_user, through: :followed, source: :follower #自分をフォローしている人
  #自分がフォローしているユーザーと自分をフォローしているユーザーを簡単に取得するために行う、throughを使った関連付け(関連付けのため、following_userとfollower_userを新たに定義)
  #1行目：フォローする人(follower)は中間テーブル(Relationshipのfollower)を通じて(through)、フォローされる人(followed)と紐づく
  #2行目：フォローされる人(followed)は中間テーブル(Relationshipのfollowed)を通じて(through)、 フォローする人(follower) と紐づく


  attachment :profile_image, destroy: false

  #バリデーションは該当するモデルに設定する。エラーにする条件を設定できる。
  validates :name, presence: true
  validates :name, length: {maximum: 20, minimum: 2}
  validates :introduction, length: {maximum:50}

  #ユーザーをフォローする
  def follow(user_id)
    follower.create(followed_id: user_id)
  end

  #ユーザーのフォローを外す
  def unfollow(user_id)
    follower.find_by(followed_id: user_id).destroy
  end

  #フォローしていればtrueを返す
  def following?(user)
    following_user.include?(user)
  end

  def self.search(search, word)
    if search == "perfect_match"
      @user = User.where(name: "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?", "#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?", "%#{word}")
    else
      @user = User.where("name LIKE?", "%#{word}%")
    end
  end
end
