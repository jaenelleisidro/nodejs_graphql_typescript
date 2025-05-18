/*
  Warnings:

  - The values [USER,ADMIN,MODERATOR] on the enum `Service` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "Service_new" AS ENUM ('DELIVERY', 'PICKUP', 'PAYMENT');
ALTER TABLE "User" ALTER COLUMN "service" TYPE "Service_new" USING ("service"::text::"Service_new");
ALTER TYPE "Service" RENAME TO "Service_old";
ALTER TYPE "Service_new" RENAME TO "Service";
DROP TYPE "Service_old";
COMMIT;
