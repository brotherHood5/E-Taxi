-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "phone_number" VARCHAR(15) NOT NULL,
    "avatar" VARCHAR(255) DEFAULT 'https://res.cloudinary.com/dkzlalahi/image/upload/v1678277295/default_male_avatar.jpg',
    "firebase_token" VARCHAR(255) DEFAULT '',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_number_key" ON "users"("phone_number");

